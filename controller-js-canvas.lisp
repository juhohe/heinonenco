(in-package #:heinonenco)

(defun controller-js-canvas ()
  (standard-page (:title "Javascript-treeni canvas")
    (:article
    (:h1 "Juhon Javascript-canvas-treenaussivu")
     (:p "Koetan tällä sivulla vähän treenata Javascript-ohjelmointia
käyttäen html5:n canvas-elementtiä. Käytän tässäkin Common Lispin 
Parenscript-kirjastoa koodin tuottamiseen. Enköhän kokeile tässä aluksi jotakin Canvas-tutoriaalia."))
    (:article
     (:canvas :id "canvasTest" :width "200" :height "200"))))

