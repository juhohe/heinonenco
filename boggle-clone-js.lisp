(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun boggle-clone-js ()
  (ps
    (defvar *dice* (random-shuffle '("AAEEEN" "AAGLÄÄ" "AHKOPS" "HIKMNU" "AKMITV" "AJOOTT" "NISTÄÖ" "AIKLVY" "EIOSST" "EIMOTU" "ALNNRU" "AFKNPS" "ABIJSU" "EEINSU" "DEILRS" "ELRTTY")))
    (defvar *count* 180)
    (defvar *counter* (set-timeout timer 1000))
    (defvar *points* 0)
    (defvar *found-words* '())

    ((chain ($ document) ready) (lambda () (create-boggle)))
    
    (defun random-shuffle (sequence)
      (let ((randomized (list))
	    (n (length sequence)))
      
	(while (> n 0)
	  (setf randomized (append (chain sequence (splice (random n) 1))randomized))
	  (setf n (1- n))))
      randomized)
    
    (defun seconds-to-mm-ss (time-in-seconds)
      (defvar minutes (floor (/ *count* 60)))
      (defvar seconds (- time-in-seconds (* 60 minutes)))
      (stringify minutes ":" seconds))

    (defun show-score-dialog ()
      ((chain ($ "#sDialogScore") html)
       (stringify "Peli päättyi. Löysit " 
		  (length *found-words*) 
		  " sana" (if (= (length *found-words*) 1)  "n" "a") 
		  " ja sait " *points* 
		  " piste" (if (= *points* 1) "en" "ttä") 
		  ". Aloitetaan uusi peli, kun painat OK."))
      
      ;; (format nil "Peli päättyi. Löysit ~d sana~:*~[a~;n~:;a~] ja sait ~d piste~:*~[ttä~;en~:;ttä~]. Aloitetaan uusi peli, kun painat OK." (length *found-words*) *points*))

      
      (cond 
	((and 
	  (> *points* 0)
	  (or (= (chain ($ "#tdTenthScore") length) 0)
	      (> (parse-int *points*) (parse-int (chain ($ "#tdTenthScore") (html))))))
	  
	 ((chain ($ "#btnOk") hide))
	 ((chain ($ "#dGetNameForHighScore") show))
	 ((chain ($ "[name='points']") val) *points*)
	 ((chain ($ "[name='longest-word']") val) get-longest-word)))
      ((chain ($ "#dialogScore") dialog)))
    
    (defun handle-game-end ()
      ;; (alert (stringify "Peli päättyi. Löysit " (length *found-words*) " sanaa ja sait " *points* " pistettä. Aloitetaan uusi peli, kun painat ok."))

      (clear-grid)
;;      (chain ($ ".dBoggle") (off "click"))
      (chain (chain ($ ".dBoggle") (remove-class "dBoggle")) (add-class "boggleDisabled"))

      (chain ($ ".boggleControl") (attr "disabled" "disabled"))

      (show-score-dialog))

    (defun timer ()
      (setf *count* (1- *count*))
      (cond
	((<= *count* 0)
	 (handle-game-end))
	(t ((@ ($ "#sTimeLeft") html)
	    (seconds-to-mm-ss *count*))	   
	   (setf *counter* (set-timeout timer 1000)))))

    (defun mark-un-selectable (x y)
      ((chain ((chain (chain ($ ".dBoggle") remove-class)) "dBoggle") add-class) "boggleDisabled")
      ;;(chain ((chain (chain ($ ".boggleDisabled") filter))
      (chain ((chain (chain ($ ".boggleDisabled") filter))
	      (chain (chain (lambda()
			      (and 
			       (or
				(eq ((chain ($ this) data) "x") (1- x))
				(eq ((chain ($ this) data) "x")  x)
				(eq ((chain ($ this) data) "x") (1+ x)))
			       (or
				(eq ((chain ($ this) data) "y") (1- y))
				(eq ((chain ($ this) data) "y")  y)
				(eq ((chain ($ this) data) "y") (1+ y)))
			       )))))
	     (remove-class "boggleDisabled") (add-class "dBoggle")))

    (defun boggle-click-handler()      
      ;; (chain ($ ".tblBoggle") (mousedown
      ;; 			       (lambda (event)
      ;; 				 ;; If clicking with middle mouse button, submitting the selected letters.
      ;; 				 (if
      ;; 				  (and 
      ;; 				   (= (chain (event which)) 2)
      ;; 				   (equal (chain ($ "#dialogScore") (css "display")) "none"))
      ;; 				  (chain ($ "#btnCheckWord") (trigger "click"))))))

      (chain ($ ".dBoggle") 
	     (mousedown
	      (lambda (event)
		(cond 
		  ((= (chain event which) 1)
		   (let ((selectedLetter ((@ ($ this) html)))
			 (is-not-selected (@ (( @ ($ this) has-class) "dBoggle"))))
		     (cond (is-not-selected
			    ((chain ((chain ($ this) add-class) "boggleSelected") remove-class) "dBoggle")
			    ((@ ($ "#dGotLetters") append) selectedletter)
			    (mark-un-selectable ((@ ($ this) data) "x") ((@ ($ this) data) "y"))))))
		  (t
		   (chain ($ "#btnCheckWord") (trigger "click"))))))))

      (defun clear-grid ()
	((chain ((chain (chain ($ ".boggleSelected, .boggleDisabled") remove-class)) "boggleSelected boggleDisabled") add-class) "dBoggle"))

      (defun boggleClearWordClickHandler ()
	(
	 (@ ($ "#btnClearWord") click)
	 (lambda ()
	   ((@ ($ "#dGotLetters") html) "")
	   (clear-grid)
	   )))

      (defun boggleStartOverClickHandler ()
	(
	 (@ ($ "#btnStartOver") click)
	 ;;	 (chain (chain window location) (reload)))
	 (lambda ()
	   (chain (chain window location) (reload)))))     

      (defun get-longest-word()
	(chain *found-words* (sort (lambda (a b) (- (chain b length) (chain a length))))0))

      (defun dialog-close-handler ()      
	((chain ($ "#btnOk") click) 
	 (lambda () 
	   ((chain ($ "#dialogScore") dialog) "close")))

	((chain ($ "#btnSaveHighScore") click)
	 (lambda ()	
	   (let ((player-name ((chain ($ "[name='player-name']") val))))
	     (cond ((> (length player-name) 0)				 
		    (chain ((chain $ ajax) (create type "post" 
						   url "save-high-score"
					;				 async "false"
						   data (create player-name player-name points *points* longest-word (get-longest-word))))))))
	   
	   ((chain ($ "#dialogScore") dialog) "close")))
	
	((chain ($ "#dialogScore") on) "dialogclose" 
	 (lambda (event ui)
	   (setf *counter* ((@ window clear-timeout) *counter*))

	   (set-timeout reload-window 1000))))

      (defun reload-window ()
	(chain (chain window location) (reload)))      

      (defun boggle-end-game-click-handler ()
	((chain ($ "#btnEndGame") click) (lambda () (setf *count* 0))))

      (defun fill-boggle-grid ()
	(let ((dice-copy (chain *dice* (slice))))
	  ((@ ($ ".dBoggle") each)
	   (lambda ()
					;	   (let ((dice-copy (chain *dice* (slice))))
	     ((chain ($ this) html)
	      (getprop (chain dice-copy (pop)) (random 6)))))))
	    
;;	    (random 6 (pop *dice*)))))

	   ;; ((@ ($ this) html)	   
	   ;;  (getprop *allowed-chars* (random (- (length *allowed-chars*) 1)) ))))
      
      (defun create-boggle()
	(boggle-click-handler)
	(boggleClearWordClickHandler)
	(boggleStartOverClickHandler)
	(boggle-end-game-click-handler)
	(dialog-close-handler)
	
	(fill-boggle-grid)

	((@ ($ "#btnCheckWord") click)
	 (lambda ()
	   (defvar triedWord ((@ ($ "#dGotLetters") html)))
	   ;;	 (if (eq (find triedWord *found-words*) t)
	   (if (> ((chain *found-words* index-of) triedword) -1)
	       (progn (clear-grid)
		      ((chain ($ "#dGotLetters") empty))		       
		      return))

	   ((@ (@ ($ "#btnCheckWord, #btnClearWord")) attr) "disabled" "disabled")
	   ;; Setting game grid tiles' css to look like disabled.
	   ((@ ((@ ($ ".boggleTile") remove-class) "dBoggle") add-class) "boggleDisabled")	 
	   ((chain ((chain $ ajax) (create type "post" 
					   url "check-word"
					   async false
					   data (create tried-word triedWord)))
		   done) (
			  lambda (data) 
			   (cond 
			     ((> data 0)
			      (chain ($ "#sFoundWords") (append triedWord ", "))
			      (setf *points* (+ *points* (parse-int data)))
			      ((chain ($ "#sPoints") html) *points*)
			      (setf *found-words* (append *found-words* triedWord))))
			     ;; TODO: somehow show that the word was not accepted.
			   ((@ (@ ($ "#btnCheckWord, #btnClearWord")) remove-attr) "disabled")
			   
			   ((chain ($ "#dGotLetters") empty))		       
			   (clear-grid))))))))
