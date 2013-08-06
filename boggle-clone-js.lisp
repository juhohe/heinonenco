(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun boggle-clone-js ()
  (ps
    (defvar *allowed-chars* "aaabdeeeghiiiijkkkllmnnnnooopprrsssttttuv")
    (defvar *count* 180)
    (defvar *counter* (set-timeout timer 1000))
    (defvar *points* 0)
    (defvar *found-words* '())

    ((chain ($ document) ready) (lambda () (create-boggle)))
    
    (defun seconds-to-mm-ss (time-in-seconds)
      (defvar minutes (floor (/ *count* 60)))
      (defvar seconds (- time-in-seconds (* 60 minutes)))
      (stringify minutes ":" seconds))

    (defun show-score-dialog ()            
      ((chain ($ "#sDialogScore") html) (stringify "Peli päättyi. Löysit "(length *found-words*) " sanaa ja sait " *points* " pistettä. Aloitetaan uusi peli, kun painat OK."))
      ;;      (chain ($ "#sDialogScore"))

      (cond 
	((> *points* 0)
	 ((chain ($ "#btnOk") hide))
	 ((chain ($ "#dGetNameForHighScore") show))))

      ((chain ($ "#dialogScore") dialog)))
    
    (defun handle-game-end ()
      ;; (alert (stringify "Peli päättyi. Löysit " (length *found-words*) " sanaa ja sait " *points* " pistettä. Aloitetaan uusi peli, kun painat ok."))

      (show-score-dialog))

    ;;      ((chain ($ "#dialogScore") dialog))

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

    (defun boggleClickHandler()
      (
       (@ ($ ".dBoggle") click)
       (lambda ()
	 (let ((selectedLetter ((@ ($ this) html)))
	       (is-not-selected (@ (( @ ($ this) has-class) "dBoggle"))))
	   (cond (is-not-selected
		  ((chain ((chain ($ this) add-class) "boggleSelected") remove-class) "dBoggle")
		  ((@ ($ "#dGotLetters") append) selectedletter)
		  (mark-un-selectable ((@ ($ this) data) "x") ((@ ($ this) data) "y"))))))))

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

    (defun dialog-close-handler ()      
      ((chain ($ "#btnOk") click) 
       (lambda () 
	 ((chain ($ "#dialogScore") dialog) "close")))

      ((chain ($ "#btnSaveHighScore") click)
       (lambda ()	
	 ;;	 (setq first-post (make-instance 'blog-post :title "Hello blog world"
	 ;;				:body "First post!"))
	 (let ((player-name ((chain ($ "[name='player-name']") val))))
	   (cond ((> (length player-name) 0)				 
		 (chain ((chain $ ajax) (create type "post" 
						 url "save-high-score"
						 async "false"
						 data (create player-name player-name points *points* words *found-words*)))))))

	   ((chain ($ "#dialogScore") dialog) "close")))
      
      ((chain ($ "#dialogScore") on) "dialogclose" 
       (lambda (event ui)	 
	 (setf *counter* ((@ window clear-timeout) *counter*))
	 (chain (chain window location) (reload)))))

    (defun create-boggle()
      (boggleClickHandler)
      (boggleClearWordClickHandler)
      (boggleStartOverClickHandler)    
      (dialog-close-handler)
      
      ((@ ($ ".dBoggle") each)
       (lambda ()
	 ((@ ($ this) html) (getprop *allowed-chars* (random (- (length *allowed-chars*) 1)) ))))

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
			 ((@ (@ ($ "#btnCheckWord, #btnClearWord")) remove-attr) "disabled")

			 ((chain ($ "#dGotLetters") empty))		       
			 (clear-grid))))))))
