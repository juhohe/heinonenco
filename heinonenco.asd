;;;; heinonenco.asd

(asdf:defsystem #:heinonenco
  :serial t
  :description "Nettisivut Lispin ja HTML5-tekniikoiden opettelua varten."
  :author "Juho Antti Heinonen <juho.heinonen@yap.fi>"
  :license "BSD License"
  :depends-on (#:hunchentoot
               #:cl-who
               #:parenscript
               #:css-lite
	       #:voikko
;;	       #:elephant
	       #:clsql
	       #:cl-libxml2
	       #:cl-ppcre)
;;               #:ht-simple-ajax)
  :components ((:file "package")
               (:file "heinonenco")
               ;; (:file "page-helpers")
               (:file "controller-js-code")
               ;; (:file "controller-js-simple")
               ;; (:file "controller-js-canvas")

	       (:file "boggle-clone")
;;	       (:file "grammatical-case-game")

               (:file "controller-css")
	       (:file "boggle-clone-js")))

