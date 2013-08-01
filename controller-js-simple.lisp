(in-package #:heinonenco)

(defun controller-js-simple ()
  (standard-page (:title "Javascript-treeni simppelit")
;;    (princ (ht-simple-ajax:generate-prologue *ajax-processor*))
    (:article
     (:h1 "Juhon Javascript-treenaussivu")
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia. Käytän
Common Lispin Parenscript-kirjastoa koodin tuottamiseen."))
    (:article
     (:p (:button :id "btnTest" "Klikkaa!")
	 (:input :id "iDateTest" :type "text")))))
    ;; (:article
    ;;  (:p "Please enter your name: " 
    ;;       (:input :id "name" :type "text"))
    ;;   (:p (:a :href "javascript:ajax_say_hi()" "Say Hi!")))))
