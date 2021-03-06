;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))

(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                           :port 80
                                           :document-root *application-path*
                                           :error-template-directory (stringify *application-path* "errors/")))

(defun create-acceptor-with-another-port (&optional (port 8888))
  (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
				     :port port
				     :document-root *application-path*
				     :error-template-directory (stringify *application-path* "errors/"))))

;; See http://msnyder.info/posts/2011/07/lisp-for-the-web-part-ii/
;; Making it easier to use jQuery with Parenscript.
(defmacro $$ ((selector event-binding) &body body)
  `((chain ($ ,selector) ,event-binding) 
    (lambda () ,@body)))

(defmacro $$$ ((selector event-binding))
  `(chain ($ ,selector) ,event-binding))

(parenscript:import-macros-from-lisp '$$)
(parenscript:import-macros-from-lisp '$$$)

(clsql:enable-sql-reader-syntax)

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
	     	    :media "screen and (min-width: 65em)"
                    :href "styles/desktop.css")
             (:link :type "text/css"
                    :rel "stylesheet"
		    :media "screen and (min-width: 31em) and (max-width: 64.99em)"
                    :href "styles/tablet.css")
	     (:link :type "text/css"
                    :rel "stylesheet"
	     	    :media "screen and (max-width: 30.99em)"
                    :href "styles/mobile.css")
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
		 (:li (:a :href "boggle-clone" "Sanapeli")))))
	      ,@body)
	     (:script :type "application/javascript"
		      :src "scripts/jquery-1.9.1.js")
	     (:script :type "application/javascript"
		      :src "scripts/jquery-ui.js")
	     (:script :type "application/javascript"
		      :src "scripts/ui.datepicker-fi.js")
	     (:script :type "application/javascript"
		      :src "scripts/code.js")            	    
	     ,page-scripts))))

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
       (create-regex-dispatcher "^/styles/desktop.css" 'controller-css-desktop)
       (create-regex-dispatcher "^/styles/tablet.css" 'controller-css-tablet)
       (create-regex-dispatcher "^/styles/mobile.css" 'controller-css-mobile)
       (create-regex-dispatcher "^/scripts/code.js" 'controller-js-code)
       (create-regex-dispatcher "^/scripts/boggle-clone.js" 'boggle-clone-js)
       (create-regex-dispatcher "^/$" 'controller-main-page)
       ;; (create-regex-dispatcher "^/js-simple" 'controller-js-simple)
       ;; (create-regex-dispatcher "^/js-canvas" 'controller-js-canvas)
       (create-regex-dispatcher "^/boggle-clone" 'controller-boggle-clone)
       (create-regex-dispatcher "^/check-word" 'controller-check-word)
       (create-regex-dispatcher "^/computer-score" 'controller-computer-score)
       (create-regex-dispatcher "^/save-high-score" 'controller-save-high-score)))

(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:article
     (:h1 "Tervetuloa kotisivuilleni!")
     (:p "Koetan tuoda tänne jotakin mielekästä aineistoa. Toistaiseksi on vain Boggle-pelin säännöillä pelattava sanapeli."))))

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

  (clsql:enable-sql-reader-syntax)

  (or (clsql:connected-databases)
      (clsql:connect "scores.db" :database-type :sqlite3))

  (let (( all-scores (clsql:query "select player_name, points, longest_word, timestamp from high_score")))
    
    ;; (let (( all-scores (clsql:select [player-name] [points] [longest-word] [timestamp] 
    ;; 					 :from [high-score]
    ;; 					 :flatp t)))
    (clsql:disconnect :database "scores.db")
    
    (setf all-scores (sort all-scores #'(lambda (x y)	
					  (if (not (numberp (second x)))
					      (setf (second x) (or (parse-integer (second x) :junk-allowed t) 0)))
					  (if (not (numberp (second y)))
					      (setf (second y) (or (parse-integer (second y) :junk-allowed t) 0)))
					  (> (second x) (second y)))))

    (loop :repeat 10 :for score-item :in all-scores :collect score-item)))

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

