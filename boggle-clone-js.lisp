(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun boggle-clone-js ()
  (ps
    (defvar *dice* (random-shuffle '("AAEEEN" "AAGLÄÄ" "AHKOPS" "HIKMNU" "AKMITV" "AJOOTT" "NISTÄÖ" "AIKLVY" "EIOSST" "EIMOTU" "ALNNRU" "AFKNPS" "ABIJSU" "EEINSU" "DEILRS" "ELRTTY")))
    (defvar *count* 180)
    (defvar *counter* (set-timeout timer 1000))
    (defvar *points* 0)
    (defvar *found-words* '())
    (defvar *grid-string* "")
    (defvar *computers-words* "")
    (defvar *computers-score* 0)

    ($$ (document ready) (create-boggle))

    ;;((chain ($ document) ready) (lambda () (create-boggle)))
    
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

    (defun pretty-print-computers-words()
      (let ((words (chain *computers-words* (to-string))))	
	(chain words (replace (regex "/,/gi") ", "))))

    ;; (defun wait-for-element ()
    ;;   (if (eql (typeof *computers-points*) undefined)
    ;; 	  (set-timeout (lambda ()
    ;; 			 (wait-for-element))250)))

    (defun show-score-dialog ()
      ;; (while (equal *computers-points* undefined)
      ;; 	(chain console (log "moro")))
      
;;     (wait-for-element)
       
      ((chain ($ "#sDialogScore") html)
       (stringify "<p>Peli päättyi. Löysit " 
		  (length *found-words*) 
		  " sana" (if (= (length *found-words*) 1)  "n" "a") 
		  " ja sait " *points* 
		  " piste" (if (= *points* 1) "en" "ttä")
		  ". Aloitetaan uusi peli, kun painat OK.<br/></br>"
		  "Tietokone löysi " (length *computers-words*) " sanaa ja "
		  "sai " *computers-points* " pistettä. "
		  "Sanat olivat seuraavat:</br></br> "
		  (pretty-print-computers-words)
		  "</p>"))

      (cond 
	((and 
	  (> *points* 0)
	  (or (= (chain ($ "#tdTenthScore") length) 0)
	      (> (parse-int *points*) (parse-int (chain ($ "#tdTenthScore") (html))))))
	  
	 ($$$ ("#btnOk" (hide)))
	 ($$$ ("#dGetNameForHighScore" (show)))
	 ($$$ ("[name='points']" (val *points*)))
	 ($$$ ("[name='longest-word']" (val get-longest-word)))))
      (chain ($ "#dialogScore") (dialog (create "width" 500))))
    
    (defun get-computers-points ()
      (chain (chain ((chain $ ajax) (create type "post" 
    				     url "computer-score"
;;    				     async false
    				     data (create grid-string *grid-string*)))
    		    (done (lambda (results)
			    (setf result-array (chain *json* (parse results)))
    			    (setf *computers-points* (chain result-array (shift)))
    			    (setf *computers-words* result-array)
			    (chain ($ "#btnEndGame") (attr "disabled" nil)))))))
    (defun handle-game-end ()
      ;; (alert (stringify "Peli päättyi. Löysit " (length *found-words*) " sanaa ja sait " *points* " pistettä. Aloitetaan uusi peli, kun painat ok."))

      (clear-grid)
;;      (chain ($ ".dBoggle") (off "click"))
      (chain (chain ($ ".dBoggle") (remove-class "dBoggle")) (add-class "boggleDisabled"))      

      (chain ($ ".boggleControl") (attr "disabled" "disabled"))
     
      (chain ($ "#btnEndGame") (attr "disabled" "disabled"))

;;      (get-computers-points)

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
      ;; Triggering word check if pressed space or enter.
      (chain ($ document)
	     (keypress
	      (lambda (e)
		(if (or (= (chain e which) 32) (= (chain e which) 13))
		    ($$$ ("#btnCheckWord" (trigger "click")))))))



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
		  ;; Checking word if not the leftmost mouse button clicked.
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
	(let ((dice-copy (chain *dice* (slice)))
	      (letter ""))
	  ((@ ($ ".dBoggle") each)
	   (lambda ()
	     (setf letter (getprop (chain dice-copy (pop)) (random 6)))
	     (setf *grid-string* (concatenate 'string *grid-string* letter))
	     ((chain ($ this) html) letter)))
	(get-computers-points)))
      
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
