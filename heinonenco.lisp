;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))
(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
					   :port 8888
					   :document-root *application-path*
					   :error-template-directory (stringify *application-path* "errors/")))

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
       (create-regex-dispatcher "^/style.css" 'controller-css)
       (create-regex-dispatcher "^/scripts/code.js" 'controller-js-code)
       (create-regex-dispatcher "^/$" 'controller-main-page)
       (create-regex-dispatcher "^/js-simple" 'controller-js-simple)
       (create-regex-dispatcher "^/js-canvas" 'controller-js-canvas)))

(defun controller-main-page ()
  (standard-page (:title "Juho Antti Heinosen kotisivut")
    (:h1 "Tervetuloa uusille hienoille Lispillä tehdyille kotisivuilleni!")
    (:article
     (:p "Koetan vain opetella Lisp-ohjelmointia ja näillä sivuilla ajattelin
harjoitella sitä. Tulikohan tämä teksti ruudulle?"))))

(defun controller-js-canvas ()
  (standard-page (:title "Javascript-treeni canvas")
    (:h1 "Juhon Javascript-canvas-treenaussivu")
    (:article
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia
käyttäen html5:n canvas-elementtiä. Käytän tässäkin Common Lispin 
Parenscript-kirjastoa koodin tuottamiseen. Vielä en ole mitään laittanut tälle sivulle."))))

(defun controller-404 ()
  (standard-page (:title "Virhe 404 - sivua ei löytynyt")
    (:h1 "Virhe 404 - sivua ei löytynyt!")
    (:article
     (:p :style "text-align: center;" "Palvelin ei löytänyt sivua osoitteesta, johon pyrit."
	 (:img :src "/img/lisplogo_flag_128.png" )))))

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

