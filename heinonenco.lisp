;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))

(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                           :port 8888
                                           :document-root *application-path*
                                           :error-template-directory (stringify *application-path* "errors/")))

(defparameter *db-file-path* (merge-pathnames *application-path* "scores.db"))
(defparameter *elephant-store* (elephant:open-store '(:clsql (:sqlite3 "/home/juhohe/Documents/SharedSection/src/lisp/heinonenco/scores.db"))))

					; Container for all our high scores
(defvar *high-scores* (or (elephant:get-from-root "high-scores")
			  (let ((high-scores (elephant:make-pset)))
			    (elephant:add-to-root "high-scores" high-scores)
			    high-scores)))

(defmacro standard-page ((&key title page-scripts) &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"
            :xml\:lang "fi" 
            :lang "fi"
            (:head 
             (:meta :http-equiv "Content-Type" 
                    :content    "text/html;charset=utf-8")
             (:title ,title)
             (:link :type "text/css"
                    :rel "stylesheet"
                    :href "styles/style.css")
             (:link :type "text/css"
                    :rel "stylesheet"
                    :href "styles/jquery-ui-1.10.2.custom.css"))
	    (:body
	     (:section
	      (:header
	       (:h1 "Juho A. Heinosen kotisivut")
	       (:nav
		(:ul
		 (:li (:a :href "/" "Etusivu"))
		 ;; (:li (:a :href "js-simple" "Javascript-simppelit"))
		 ;; (:li (:a :href "js-canvas" "Javascript-canvas"))
		 (:li (:a :href "boggle-clone" "Sanapeli")))))
	      ,@body)
	     (:script :type "text/javascript"
		      :src "scripts/jquery-1.9.1.js")
	     (:script :type "text/javascript"
		      :src "scripts/jquery-ui.js")
	     (:script :type "text/javascript"
		      :src "scripts/ui.datepicker-fi.js")
	     (:script :type "text/javascript"
		      :src "scripts/code.js")            	    
	    ,page-scripts))))

;;(defparameter *ajax-processor*
;;  (make-instance 'ht-simple-ajax:ajax-processor :server-uri "/ajax"))
;;  (make-instance 'ajax-processor :server-uri "/ajax"))

;;(ht-simple-ajax:defun-ajax say-Hi (name) (*ajax-processor*)
;;  (concatenate 'string "Hi " name ", nice to meet you."))

(defun start-server ()
  (handler-case
      (progn
        (hunchentoot:start *my-acceptor*)
        (format nil "The server is now listening to port ~a." 
                (acceptor-port *my-acceptor*)))
    (hunchentoot::hunchentoot-simple-error () 
      (format nil "The server is already listening to port ~a." 
              (acceptor-port *my-acceptor*)))
    (usocket:address-in-use-error ()
      (format nil "The address is already in use!"))))

(defun stop-server ()
  "Stops the running of the server."
  (handler-case
      (progn
        (hunchentoot:stop *my-acceptor*)
        "The server has been stopped successfully.")
    (simple-error () "The server has already been stopped.")
    (unbound-slot () "The server has not been started and thus the acceptor has not been bound yet.")))

(setq *dispatch-table*
      (list
       (create-regex-dispatcher "^/styles/style.css" 'controller-css)
       (create-regex-dispatcher "^/scripts/code.js" 'controller-js-code)
       (create-regex-dispatcher "^/scripts/boggle-clone.js" 'boggle-clone-js)
       (create-regex-dispatcher "^/$" 'controller-main-page)
       (create-regex-dispatcher "^/js-simple" 'controller-js-simple)
       (create-regex-dispatcher "^/js-canvas" 'controller-js-canvas)
       (create-regex-dispatcher "^/boggle-clone" 'controller-boggle-clone)
       (create-regex-dispatcher "^/check-word" 'controller-check-word)
       (create-regex-dispatcher "^/save-high-score" 'controller-save-high-score)))
;;      (ht-simple-ajax:create-ajax-dispatcher *ajax-processor*)))

(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:article
     (:h1 "Tervetuloa Lispillä tehdyille kotisivuilleni!")
     (:p "Olen kiinnostunut Lisp-ohjelmoinnista. Näillä sivuilla on siihen liittyviä harjoitustöitäni."))))

(defun controller-404 ()
  (standard-page (:title "Virhe 404 - sivua ei löytynyt")
    (:article
     (:h1 "Virhe 404 - sivua ei löytynyt!")
     (:p :style "text-align: center;" "Palvelin ei löytänyt sivua osoitteesta, johon pyrit."
         (:img :src "/img/lisplogo_flag_128.png")))))

(elephant:defpclass high-score ()
  ((player-name :initarg :player-name
		:accessor player-name)
   (points :initarg :points
	   :accessor points)
   (longest-word :initarg :longest-word
		 :accessor longest-word
		 :initform "")
   (timestamp :initarg :timestamp
              :accessor timestamp
              :initform (get-universal-time))))

(defun controller-boggle-clone ()
  ;; Open the store where our data is stored

  (standard-page (:title "Sanapeli" :page-scripts (:script :type "text/javascript" :src "scripts/boggle-clone.js"))
    (:article
     (:h1 "Sanapeli")
     (:div :id "dWordGame"
           (:div :id "dGotLetters" :style "display:block;")
           (:button :id "btnCheckWord" :style "display: inline"
                    "Tarkista sana")
	   (:button :id "btnClearWord" :style "display: inline;" "Tyhjennä valinta")

	   (:button :id "btnStartOver" "Aloita uusi peli"))
     (:div :id "dGameGrid"

	   (:span :id "lblTimeLeft" "aikaa jäljellä")
	   (:span :id "sTimeLeft" :style "display:block;")
	   (loop for i from 0 to 3 do
		(loop for j from 0 to 3 do
		     (htm 
		      (:div :data-x j :data-y i :class "dBoggle boggleTile")))
		(htm
		 (:br)))
	   (:span :id "sFoundWords" :style "display:inline; font-weight: Bold;")
	   (:span :id "sPoints" "0"))

     (:div :id "dRightSide"
	   (:div :id "dInstructions"
		 (:h2 "Pelin kulku")
		 "Pelissä on tavoitteena kerätä mahdollisimman paljon sanoja. Sanojen pituuden pitää olla vähintään 3 kirjainta. 3 ja 4 kirjaimen pituisista sanoista saa yhden pisteen, sitä pitemmistä sanoista saa yhden lisäpisteen jokaisesta neljän kirjaimen jälkeen tulevasta kirjaimesta. Verbeistä hyväksytään vain persoonattomat muodot. Nomineista (esim. pronomineista ja substantiiveista) hyväksytään yksikön ja monikon nominatiivit. Erisnimiä ei hyväksytä."))
     
     (:div :id "dHighScores"
	   (:h2 "Parhaat tulokset")
	   

	   
	  	   
	   )




     (:div :id "dialogScore" :style "display:none;"
	   (:span :id "sDialogScore")
	   (:button :id "btnOk" "OK.")
	   (:div :id "dGetNameForHighScore" :style "display:none;"
		 (:p "Onneksi olkoon! Pääsit kunniatauluun. Jos annat nimesi, tallennetaan tuloksesi top 10 -listaan.")
		 (:label :for "player-name" "Nimi: ")
		 (:input :type "text" :name "player-name")
		 (:button :id "btnSaveHighScore" "OK"))))))



(defun controller-save-high-score ()
  (with-open-file (stream  (merge-pathnames *application-path* "test.txt") :direction :output :if-exists :supersede)
    (format stream (post-parameter "playerName")))
			   
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (save-high-score (post-parameter "points")
			  (post-parameter "foundWords")
			  (post-parameter "playerName")))))

(defun save-high-score (points found-words player-name)
  (elephant:insert-item (make-instance 'high-score 
			      :points points 
			      :player-name player-name 
			      :longest-word (car (sort found-words #'(lambda (x y) (> (length x) (length y))))))  *high-scores*))

;;(car (sort found-words #'(lambda (x y) (> (length x) (length y))))))))))


	;; (score-item (make-instance 'high-score 
	;; 			   :points points
	;; 			   :player-name player-name
	;; 			   :longest-word longest-word)))))

	
(defun controller-check-word ()
  (cond ((eq (hunchentoot:request-method*) :POST)	
	 (setf (header-out "score") (stringify (check-word-score (post-parameter "triedWord")))))))

(defun check-word-score (word-to-check)
  (defparameter *voikko* (voikko:initialize))
  ;; (let ((analyses (voikko:with-instance (i)
  ;; 		    (voikko:analyze i word-to-check))))
  (let ((analyses (voikko:analyze *voikko* word-to-check)))
    (if (is-word-accepted analyses)
	(cond ((equal 3 (length word-to-check))
	       1)
	      ((equal 4 (length word-to-check))
	       1)
	      (t
	       (- (length word-to-check) 3)))
	0)))

(defun is-word-accepted (analyses)
  (loop for el in analyses when		    
       (or
	;; particles
	(equal (cdr (assoc "CLASS" el :test #'string=)) "seikkasana")
       
	;; verbs (only non-personal verb forms are accepted
	(and (equal (cdr (assoc "CLASS" el :test #'string=)) "teonsana")
	     (equal (cdr (assoc "PERSON" el :test #'string=)) nil))
	
	;; nouns, adjectives, and pronouns
	(and
	 ;; excluding proper nouns ("erisnimet" in Finnish)
	 ((lambda (word-class) 
	    (not (equal (subseq word-class (- (length word-class) 4)) "nimi")))
	  (cdr (assoc "CLASS" el :test #'string=)))
	 (equal (cdr (assoc "SIJAMUOTO" el :test #'string=)) "nimento")))
     return el))
