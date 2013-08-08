;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))

(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                           :port 8888
                                           :document-root *application-path*
                                           :error-template-directory (stringify *application-path* "errors/")))

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


;;(clsql:start-sql-recording)

(clsql:enable-sql-reader-syntax)

;;(defparameter *db-spec* '(:clsql (:sqlite3 "scores.db")))
;;(defparameter *elephant-store* (elephant:open-store *db-spec*))

;;(elephant:open-store *db-spec*)
					; Container for all our high scores
;; (defparameter *high-scores* (or (elephant:get-from-root "high-scores")
;; 			  (let ((high-scores (elephant:make-pset)))
;; 			    (elephant:add-to-root "high-scores" high-scores)
;; 			    high-scores)))

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

;; (def-view-class header()
;;   ((player-name :initarg :player-name
;; 		:accessor player-name)
;;    (points :initarg :points
;; 	   :accessor points)
;;    (longest-word :initarg :longest-word
;; 		 :accessor longest-word
;; 		 :initform "")
;;    (timestamp :initarg :timestamp
;;               :accessor timestamp
;;               :initform (get-universal-time))))

(defun get-10-highest-scores ()
  ;;  (clsql:with-transaction ()

  (or (clsql:connected-databases)
      (clsql:connect "scores.db" :database-type :sqlite3))
  
  (let (( all-scores (clsql:select [player-name] [points] [longest-word] [timestamp] 
					 :from [high-score]
					 :flatp t)))
  (clsql:disconnect :database "scores.db")
  
  (sort all-scores #'(lambda (x y)	
		   (if (not (numberp (second x)))
		       (setf (second x) (or (parse-integer (second x) :junk-allowed t) 0)))
		   (if (not (numberp (second y)))
		       (setf (second y) (or (parse-integer (second y) :junk-allowed t) 0)))
		   (> (second x) (second y))))))

  ;; (sort all-scores #'(lambda (x y) 
  
  ;; ))

;; (let ((sorted-scores	 
;; 	 (sort (copy-list (elephant:get-instances-by-class 'high-score))
;; 	       #'(lambda (x y)
;; 		   (if (not (numberp (points x)))
;; 		       (setf (points x) (or (parse-integer (points x) :junk-allowed t) 0)))
;; 		   (if (not (numberp (points y)))
;; 		       (setf (points y) (or (parse-integer (points y) :junk-allowed t) 0)))
;; 		   (> (points x) (points y))))))
;;   (loop :repeat 10 :for score-item :in sorted-scores :collect score-item)))

;; (elephant:with-open-store (*db-spec*)
;;   (elephant:get-instances-by-class 'high-score)))



;; (setq sorted-scores      
;; 	(sort (elephant:get-instances-by-class 'high-score)
;; 	      #'(lambda (x y)
;; 		  (if (not (numberp (points x)))
;; 		      (setf (points x) (parse-integer (points x))))
;; 		  (if (not (numberp (points y)))
;; 		      (setf (points y) (parse-integer (points y))))
;; 		  (> (points x) (points y)))))
;; (loop :repeat 10 :for score-item :in sorted-scores :collect score-item))

(defun get-formatted-time-from-universal-time (timestamp)
  (if (not (numberp timestamp))
      (setf timestamp (parse-integer timestamp)))

  (multiple-value-bind
	(second minute hour date month year day-of-week dst-p tz)
      (decode-universal-time timestamp)
    (format t "~d.~d.~d ~d:~2,'0d:~2,'0d"
	    date
	    month
	    year
	    hour
	    minute
	    second)))


(defun controller-boggle-clone ()
  ;; Open the store where our data is stored

  (standard-page (:title "Sanapeli" :page-scripts (:script :type "text/javascript" :src "scripts/boggle-clone.js"))
    (:article
     (:h1 "Sanapeli")
     (:div :id "dWordGameControls"
           (:button :id "btnCheckWord" :class "boggleControl" :style "display: inline"
                    "Tarkista sana")
	   (:button :id "btnClearWord" :class "boggleControl"  "Tyhjennä valinta")
	   (:button :id "btnEndGame" "Lopeta peli etuajassa")

	   (:button :id "btnStartOver" :class "boggleControl" "Aloita uusi peli")
	   (:br)
	   (:span :id "dGotLettersLabel" :style "display:inline;" "Valitut kirjaimet: ")
	   (:div :id "dGotLetters" :style "display:inline-block;"))
     
     (:div :id "dGameGrid"

	   (:span :id "lblTimeLeft" "aikaa jäljellä")
	   (:span :id "sTimeLeft" :style "display:block;" "3:00")
	   (:table :id "tblBoggle"
		   (loop for i from 0 to 3 
		      do
			(htm (:tr
			      (loop for j from 0 to 3 
				 do
				   (htm 
				    (:td :data-x j :data-y i :class "dBoggle boggleTile")))))))
	   
	   (:br)

	   (:span :id "sFoundWordsLabel" :style "display:inline;"  "Löydetyt sanat: ")
	   (:span :id "sFoundWords" :style "display:inline; font-weight: Bold;")      
	   (:span :id "sPointsLabel" :style "display:inline;"
		  "Pisteet: ")
	   (:span :id "sPoints" "0"))

     (:div :id "dRightSide"
	   (:div :id "dInstructions"
		 (:h2 "Peliohjeet")
		 (:p "Pelissä on tavoitteena kerätä mahdollisimman paljon sanoja. Sanoja kerätään siten, että valitaan napautetaan kirjaimia hiirellä vierekkäin sijaitsevia kirjaimia ja täten muodostetaan kirjaimista sanoja. Sana lähetetään tarkistettavaksi painamalla hiiren kakkos- tai kolmospainiketta tai klikkaamalla \"Tarkista sana\"-painiketta.")

		 (:p "Sanojen pituuden pitää olla vähintään 3 kirjainta. 3 ja 4 kirjaimen pituisista sanoista saa yhden pisteen, sitä pitemmistä sanoista saa yhden lisäpisteen jokaisesta neljän kirjaimen jälkeen tulevasta kirjaimesta. Verbeistä hyväksytään vain persoonattomat muodot. Nomineista (esim. pronomineista ja substantiiveista) hyväksytään yksikön ja monikon nominatiivit. Erisnimiä ei hyväksytä."))
	   
	   (:div :id "dHighScores"
		 (:h2 "Parhaat tulokset")
		 (:table :id "tblHighScores"
			 (:tr
			  (:th)
			  (:th "Nimi")
			  (:th "Pisteet")
			  (:th "Pisin sana")
			  (:th "Ajankohta"))
			 (let ((position 1))
			   (loop for score-item in (get-10-highest-scores) do
				(htm (:tr		      		      
				      (:td (str (stringify position ".")))
				      (:td (str (first score-item)))
				      (:td (str (second score-item)))
				      (:td (str (third score-item)))
				      (:td (str (get-formatted-time-from-universal-time (car (last score-item)))))))
				(setq position (1+ position))))))

	   (:div :id "dialogScore" :style "display:none;"
		 (:span :id "sDialogScore")
		 (:button :id "btnOk" "OK.")	   
		 (:div :id "dGetNameForHighScore" :style "display:none;"	       
					;		 (:form :action "save-high-score" :method "post"
		       (:p "Onneksi olkoon! Pääsit kunniatauluun. Jos annat nimesi, tallennetaan tuloksesi top 10 -listaan.")
		       (:label :for "player-name" "Nimi: ")
		       (:input :type "text" :name "player-name")
		       (:button :id "btnSaveHighScore" "OK")))))))
;; (:input :type "text" :name "longest-word"
;; 	:style "display: none;")
;; (:input :type "text" :name "points"
;; 	:style "display: none;")
;; (:input :type "submit" :id "btnSaveHighScore")))))))

(defun controller-save-high-score ()
  ;;  (break)
  ;; (with-open-file (stream  (merge-pathnames *application-path* "test.txt") :direction :output :if-exists :supersede)
  ;; (format stream (post-parameter "player-name")))
  ;; (signal (post-parameter "points"))
  ;; (signal (post-parameter "longestWord"))
  ;; (signal (post-parameter "playerName"))


  ;;(break)
  
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (save-high-score (post-parameter "points")
			  (post-parameter "longestWord")
			  (post-parameter "playerName")))))

(defun save-high-score (points longest-word player-name)
  (or (clsql:connected-databases)
      (clsql:connect "scores.db" :database-type :sqlite3))
  (defparameter new-id (1+ (or (car (clsql:select [max [id]] :from [high-score]	
					   :flatp t))0)))
  (defparameter row-timestamp (get-universal-time))
  
  (defparameter value-list (list new-id  player-name points longest-word row-timestamp))

  (clsql:insert-records :into [high-score]
			:attributes '(id player_name points longest_word timestamp)
			:values value-list)

					;(timestamp (get-universal-time)))

    

    ;; (signal points)
    ;; (signal longest-word)
    ;; (signal new-id)
    ;; (break)

    ;; (clsql:insert-records :into [high-score]
    ;; 			  :attributes '([id] [points] [player-name] [longest-word] [timestamp])
    ;; 			  :values '(5 points player-name longest-word timestamp)))
    (clsql:disconnect :database "scores.db")))
;;  (Elephant:with-open-store (*db-spec*) 
  
;;  (elephant:with-open-store (*db-spec*)
    
  ;; (elephant:with-transaction ()
  ;;   (make-instance 'high-score 
  ;; 		   :points points
  ;; 		   :player-name player-name
  ;; 		   :longest-word longest-word)))
;;       (elephant:insert-item score-item *high-scores*))   

;; (elephant:with-transaction ()
;;   (setq score-item (make-instance 'high-score 
;; 				    :points points
;; 				    :player-name player-name
;; 				    :longest-word longest-word))
;;   (elephant:insert-item score-item *high-scores*)))

					;(car (sort found-words #'(lambda (x y) (> (length x) (length y))))))  *high-scores*))

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
	     (null (cdr (assoc "PERSON" el :test #'string=))))
	
	;; nouns, adjectives, and pronouns
	(and
	 ;; excluding proper nouns ("erisnimet" in Finnish)
	 ((lambda (word-class) 
	    (not (equal (subseq word-class (- (length word-class) 4)) "nimi")))
	  (cdr (assoc "CLASS" el :test #'string=)))
	 (equal (cdr (assoc "SIJAMUOTO" el :test #'string=)) "nimento")
	 (null (cdr (assoc "FOCUS" el :test #'string=)))	 
	 (null (cdr (assoc "POSSESSIVE" el :test #'string=)))))
     return el))
