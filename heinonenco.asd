;;;; heinonenco.asd

(asdf:defsystem #:heinonenco
  :serial t
  :description "Nettisivut Lispin ja HTML5-tekniikoiden opettelua varten."
  :author "Juho Antti Heinonen <juho.heinonen@yap.fi>"
  :license "BSD License"
  :depends-on (#:hunchentoot
	       #:cl-who
               #:parenscript
	       #:css-lite)
  :components ((:file "package")
               (:file "heinonenco")))

