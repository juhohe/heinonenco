;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
					   :port 8080))

(defun start-server ()
  (handler-case
      (progn
	(hunchentoot:start *my-acceptor*)
	(format nil "The server is now listening to port ~a." 
		(acceptor-port *my-acceptor*)))
    (hunchentoot::hunchentoot-simple-error () 
      (format nil "The server is already listening to port ~a." 
	      (acceptor-port *my-acceptor*)))))

(defun stop-server ()
  (handler-case
      (progn
	(hunchentoot:stop *my-acceptor*)
	"The server has been stopped successfully.")
    (simple-error () "The server has already been stopped.")))

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
		      :src "jquery-1.8.3.min.js")
	     (:script :type "text/javascript"
		      :src "code.js"))
	    (:body
	     (:header
	      (:h1 "Juho A. Heinosen kotisivut")
	      (:img :src "lisp-alien.png")
	      (:nav
	       (:ul
		(:li (:a :href "main-page" "Etusivu"))
		(:li (:a :href "js-page" "Javascript-harjoittelua")))))
	     ,@body))))

(setq *dispatch-table*
 (list
  (create-regex-dispatcher "^/style.css" 'controller-css)
  (create-regex-dispatcher "^/code.js" 'controller-js-code)
  (create-regex-dispatcher "^/main-page" 'controller-main-page)
  (create-regex-dispatcher "^/js-page" 'controller-js-page)
  (create-static-file-dispatcher-and-handler
   "/lisp-alien.png"
   "~/Documents/SharedSection/src/lisp/heinonenco/img/lisplogo_128.png")
  (create-static-file-dispatcher-and-handler 
   "/jquery-1.8.3.min.js" 
   "~/Documents/SharedSection/src/lisp/heinonenco/scripts/jquery-1.8.3.min.js")))

(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:h1 "Tervetuloa uusille hienoille Lispillä tehdyille kotisivuilleni!")
    (:article
     (:p "Koetan vain opetella Lisp-ohjelmointia ja näillä sivuilla ajattelin
harjoitella sitä. Tulikohan tämä teksti ruudulle?"))))

(defun controller-js-page ()
  (standard-page (:title "Javascript-treeni")
    (:h1 "Juhon Javascript-treenaussivu")
    (:article
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia. Käytän
Common Lispin Parenscript-kirjastoa koodin tuottamiseen."))
    (:article
     (:p (:button :id "btnTest" "Klikkaa!")))))

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
