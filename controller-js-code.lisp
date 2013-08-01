(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun controller-js-code ()
  (ps 
    (defvar *allowed-chars* "aaabdeeehiiiijkkkllmnnnnooopprrsssttttuv")
    (defun boggleClickHandler()
      (
       (@ ($ ".dBoggle") click)
       (lambda ()
         (let ((selectedLetter ((@ ($ this) html)))))
         ((@ ($ "#dGotLetters") append) selectedletter))))
    
    (defun createBoggle()
      (boggleClickHandler)
      (
       
       (@ ($ ".dBoggle") each)
       (lambda ()
         ((@ ($ this) html) (getprop *allowed-chars* (random (- (length *allowed-chars*) 1)) ))))

      ((@ ($ "#btnCheckWord") click)
      (lambda ()
        (defvar triedWord ((@ ($ "#dGotLetters") html)))
        ((@ $ ajax) (create type "post" 
                            url "check-word"
                            data (create tried-word triedWord)))
        )
      ))
      


    

    ((@ ($ document) ready)
     (lambda ()

       (defvar canvas ((@ document get-element-by-id)
                       "canvasTest"))

       (if (not (eq canvas nil)) 
           (progn 
             (defvar context ((@ canvas get-context)
                              "2d"))
             (setf (@ context fill-style) "rgba(50, 120, 255, .5)")
             ((@ context fill-rect)
              15 35 250 125)
))
       ((@ ($ "#btnTest") click)
        (lambda ()
          (alert "moro")))

       (createBoggle)

       ((@ ($ "#iDateTest") datepicker))

       )
     )))

(ps (ps-html "disabled"))
