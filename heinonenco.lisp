;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))

(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                           :port 8888
                                           :document-root *application-path*
                                           :error-template-directory (stringify *application-path* "errors/")))

(defmacro standard-page ((&key title) &body body)
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
                    :href "styles/jquery-ui-1.10.2.custom.css")
             (:script :type "text/javascript"
                      :src "scripts/jquery-1.9.1.js")
             (:script :type "text/javascript"
                      :src "scripts/jquery-ui.js")
             (:script :type "text/javascript"
                      :src "scripts/ui.datepicker-fi.js")
             (:script :type "text/javascript"
                      :src "scripts/code.js"))            
            (:body
             (:section
              (:header
               (:h1 "Juho A. Heinosen kotisivut")
               (:nav
                (:ul
                 (:li (:a :href "/" "Etusivu"))
                 (:li (:a :href "js-simple" "Javascript-simppelit"))
                 (:li (:a :href "js-canvas" "Javascript-canvas"))
                 (:li (:a :href "boggle-clone" "Sanapeli")))))
              ,@body)))))

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
       (create-regex-dispatcher "^/$" 'controller-main-page)
       (create-regex-dispatcher "^/js-simple" 'controller-js-simple)
       (create-regex-dispatcher "^/js-canvas" 'controller-js-canvas)
       (create-regex-dispatcher "^/boggle-clone" 'controller-boggle-clone)
       (create-regex-dispatcher "^/check-word" 'controller-check-word)
       ))
;;      (ht-simple-ajax:create-ajax-dispatcher *ajax-processor*)))

(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:article
     (:h1 "Tervetuloa uusille hienoille Lispillä tehdyille kotisivuilleni!")
     (:p "Koetan vain opetella Lisp-ohjelmointia ja näillä sivuilla ajattelin
harjoitella sitä. Tulikohan tämä teksti ruudulle?"))))

(defun controller-404 ()
  (standard-page (:title "Virhe 404 - sivua ei löytynyt")
    (:article
     (:h1 "Virhe 404 - sivua ei löytynyt!")
     (:p :style "text-align: center;" "Palvelin ei löytänyt sivua osoitteesta, johon pyrit."
         (:img :src "/img/lisplogo_flag_128.png" )
         ))))

(defun controller-boggle-clone ()
  (standard-page (:title "Sanapeli")
    (:article
     (:h1 "Sanapeli")
     (:div :id "dWordGame"
           (:div :id "dGotLetters" :style "display:block;")
           (:button :id "btnCheckWord" :style "display: inline"
                    "Tarkista sana")
	   (:button :id "btnClearWord" :style "display: inline;" "Tyhjennä valinta")

	   (:button :id "btnStartOver" "Aloita uusi peli"))

     (:div :id "dRightSide"
	   (:div :id "dInstructions"
		 "Pelissä on tavoitteena kerätä mahdollisimman paljon sanoja. Sanojen pituuden pitää olla vähintään 3 kirjainta. 3 ja 4 kirjaimen pituisista sanoista saa yhden pisteen, sitä pitemmistä sanoista saa yhden lisäpisteen jokaisesta neljän kirjaimen jälkeen tulevasta kirjaimesta."
		 ))

     (:span :id "lblTimeLeft" "aikaa jäljellä")
     (:span :id "sTimeLeft" :style "display:block;")
     (loop for i from 0 to 3 do
	  (loop for j from 0 to 3 do
	       (htm 
		(:div :data-x j :data-y i :class "dBoggle")))
	  (htm
	   (:br)))
     (:span :id "sFoundWords" :style "display:inline; font-weight: Bold;")
     (:span :id "sPoints" "0")
     
     )
    

    ))

(defun controller-check-word ()
  (cond ((eq (hunchentoot:request-method*) :GET)
         (/ 0 0))
        ((eq (hunchentoot:request-method*) :POST)
	 (setf (header-out "score") (stringify (check-word-score (post-parameter "triedWord")))))))

(defun check-word-score (word-to-check)
  (let ((analyses (voikko:with-instance (i)
		    (voikko:analyze i word-to-check))))
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
