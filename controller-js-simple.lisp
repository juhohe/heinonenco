(in-package #:heinonenco)

(defun controller-js-simple ()
  (standard-page (:title "Javascript-treeni simppelit")
    (:article
     (:h1 "Juhon Javascript-treenaussivu")
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia. Käytän
Common Lispin Parenscript-kirjastoa koodin tuottamiseen."))
    (:article
     (:p (:button :id "btnTest" "Klikkaa!")
	 (:input :id "iDateTest" :type "text")))))
