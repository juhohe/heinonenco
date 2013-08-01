;;;; heinonenco.lisp

(in-package #:heinonenco)

;;; "heinonenco" goes here. Hacks and glory await!
(defparameter *application-path* (asdf:system-source-directory :heinonenco))

(defparameter *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                           :port 8888
                                           :document-root *application-path*
                                           :error-template-directory (stringify *application-path* "errors/")))
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
           (:button :id "btnCheckWord" :style "display: block;"
                    "Tarkista sana")
           (loop for i from 0 to 3 do
                (loop for j from 0 to 3 do
                     (htm 
                      (:div :id (stringify i "x" j) :class "dBoggle")))
                (htm
                 (:br)))

           )
     )))

(defun controller-check-word ()
  (cond ((eq (hunchentoot:request-method*) :GET)
         (/ 0 0))
        ((eq (hunchentoot:request-method*) :POST)

         (with-open-file (stream "c:/testi/parametri.txt" :if-exists :supersede :direction :output)
           (format stream 
                   (post-parameter "triedWord"))))))
 
