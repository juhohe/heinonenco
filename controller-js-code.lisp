(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun controller-js-code ()
  (ps 
    (defvar *allowed-chars* "aaabdeeehiiiijkkkllmnnnnooopprrsssttttuv")
    (defvar *count* 180)
    (defvar *counter* (set-interval timer 1000))
    (defvar *points* 0)

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

       ((@ ($ "#iDateTest") datepicker))))

    (defun seconds-to-mm-ss (time-in-seconds)
      (defvar minutes (floor (/ *count* 60)))
      (defvar seconds (- time-in-seconds (* 60 minutes)))
      (stringify minutes ":" seconds))
    
    (defun timer ()
      (setf *count* (1- *count*))
      (if (<= *count* 0) 
	  ("game ended")
	  
	  ((@ ($ "#sTimeLeft") html)
	   (seconds-to-mm-ss *count*))))

    (defun boggleClickHandler()
      (
       (@ ($ ".dBoggle") click)
       (lambda ()
         (let ((selectedLetter ((@ ($ this) html)))))
         ((@ ($ "#dGotLetters") append) selectedletter))))
    
    (defun boggleClearWordClickHandler ()
      (
       (@ ($ "#btnClearWord") click)
       (lambda ()
         ((@ ($ "#dGotLetters") html) ""))))
    
    (defun createBoggle()
      (boggleClickHandler)
      (boggleClearWordClickHandler)
      (
       
       (@ ($ ".dBoggle") each)
       (lambda ()
         ((@ ($ this) html) (getprop *allowed-chars* (random (- (length *allowed-chars*) 1)) ))))

      ((@ ($ "#btnCheckWord") click)
       (lambda ()
	 (defvar triedWord ((@ ($ "#dGotLetters") html)))
	 ((chain ((chain $ ajax) (create type "post" 
					 url "check-word"
					 data (create tried-word triedWord)))
		 done) (
			lambda (data) 
			 (cond 
			   ((> data 0)
			    (chain ($ "#sFoundWords") (append triedWord ", "))
			    (setf *points* (+ *points* (parse-int data)))
			    ((chain ($ "#sPoints") html) *points*)))
			 ((chain ($ "#dGotLetters") empty)))))))))
			   ;; (t
			   ;;  ((chain ($ "#dGotLetters") empty)))))))))))

(ps (ps-html "disabled"))
