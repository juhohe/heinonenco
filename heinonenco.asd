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
               #:ht-simple-ajax)
  :components ((:file "package")
               (:file "heinonenco")
               (:file "page-helpers")
               (:file "controller-js-code")
               (:file "controller-js-simple")
               (:file "controller-js-canvas")
               (:file "controller-css")))

