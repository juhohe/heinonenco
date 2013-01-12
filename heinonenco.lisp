;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))
(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
					   :port 8080
					   :document-root *application-path*))

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
  (handler-case
      (progn
	(hunchentoot:stop *my-acceptor*)
	"The server has been stopped successfully.")
    (simple-error () "The server has already been stopped.")
    (unbound-slot () "The server has not been started and thus the acceptor has not been bound yet.")))

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
		    :href "style.css")
	    (:script :type "text/javascript"
		     :src "scripts/jquery-1.8.3.min.js"))
	    (:body
	     (:header
	      (:h1 "Juho A. Heinosen kotisivut")
	      (:img :src "/img/lisplogo_128.png")
	      (:nav
	       (:ul
		(:li (:a :href "main-page" "Etusivu"))
		(:li (:a :href "js-simple" "Javascript-simppelit"))
		(:li (:a :href "js-canvas" "Javascript-canvas")))))
	     ,@body
	     (:script :type "text/javascript"
		      :src "scripts/code.js")))))

(setq *dispatch-table*
 (list
  (create-regex-dispatcher "^/style.css" 'controller-css)
  (create-regex-dispatcher "^/scripts/code.js" 'controller-js-code)
  (create-regex-dispatcher "^/main-page" 'controller-main-page)
  (create-regex-dispatcher "^/js-simple" 'controller-js-simple)
  (create-regex-dispatcher "^/js-canvas" 'controller-js-canvas)))
  ;; (create-static-file-dispatcher-and-handler
  ;;  "/img/lisp-alien.png" (merge-pathnames 
  ;; 			  "img/lisplogo_128.png"
  ;; 			  *application-path*))
  ;; (create-static-file-dispatcher-and-handler
  ;;  "/img/lisp-alien.png" "/img/lisplogo_128.png")
  ;; (create-static-file-dispatcher-and-handler 
  ;;  "/scripts/jquery-1.8.3.min.js" (merge-pathnames 
  ;; 				   "scripts/jquery-1.8.3.min.js"
  ;; 				   *application-path*))))
(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:h1 "Tervetuloa uusille hienoille Lispillä tehdyille kotisivuilleni!")
    (:article
     (:p "Koetan vain opetella Lisp-ohjelmointia ja näillä sivuilla ajattelin
harjoitella sitä. Tulikohan tämä teksti ruudulle?"))))

(defun controller-js-simple ()
  (standard-page (:title "Javascript-treeni simppelit")
    (:h1 "Juhon Javascript-treenaussivu")
    (:article
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia. Käytän
Common Lispin Parenscript-kirjastoa koodin tuottamiseen."))
    (:article
     (:p (:button :id "btnTest" "Klikkaa!")))))

(defun controller-js-canvas ()
  (standard-page (:title "Javascript-treeni canvas")
    (:h1 "Juhon Javascript-canvas-treenaussivu")
    (:article
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia
käyttäen html5:n canvas-elementtiä. Käytän tässäkin Common Lispin 
Parenscript-kirjastoa koodin tuottamiseen. Vielä en ole mitään laittanut tälle sivulle."))))


(defun controller-css ()
  (setf (hunchentoot:content-type* hunchentoot:*reply*) "text/css")
  (css-lite:css
    (("header h1")
     (:font-size "160%" :text-align "center"))
    (("header img")
     (:float "right"))
    (("header nav")
     (:text-align "center"))
    (("header nav ul li")
     (:display "inline" :margin "1em"))
    (("header nav ul li a")
     (:text-decoration "None"))
    (("body")
     (:width "70%" :margin "0 auto" :font-family "sans-serif"
	     :border-left "1em solid #ccc"
	     :border-right "1em solid #ccc"
	     :border-top "1em solid #ccc"
	     :border-bottom "1em solid #ccc"
	     :padding "1em"))
    (("h1")
     (:font-size "140%" :text-align "center"))))

(defun controller-js-code ()
  (ps ((@ ($ document) ready)
      (lambda ()
	 ((@ ($ "#btnTest") click)
	  (lambda ()
	    (alert "moro")))))))
