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

    ;; TODO: Reorders the sequence given as parameter randomly.
    (defun random-shuffle (sequence)
      (let ((randomized (list))
	    (n (length sequence)))
     	(while (> n 0)
	  (setf randomized (append (chain sequence (splice (random n) 1))randomized))
	  (setf n (1- n))))
      randomized)

    ;; Formats seconds to mm:ss.
    (defun seconds-to-mm-ss (time-in-seconds)
      (defvar minutes (floor (/ *count* 60)))
      (defvar seconds (- time-in-seconds (* 60 minutes)))
      (stringify minutes ":" seconds))

    ;; Inserts commas between words found by the computer.
    (defun pretty-print-computers-words()
      (let ((words (chain *computers-words* (to-string))))	
	(chain words (replace (regex "/,/gi") ", "))))

    ;; Displays the game over dialog.
    (defun show-score-dialog ()
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
      ;; Checks if the player achieved a place in top 10.
      (cond 
	((and 
	  (> *points* 0)
	  (or (= (chain ($ "#tdTenthScore") length) 0)
	      (> (parse-int *points*) (parse-int (chain ($ "#tdTenthScore") (html))))))
	  
	 ($$$ ("#btnOk" (hide)))
	 ($$$ ("#dGetNameForHighScore" (show)))
	 ($$$ ("[name='points']" (val *points*)))
	 ($$$ ("[name='longest-word']" (val get-longest-word)))))
      ($$ ("#dialogScore" (dialog (create "width" 500)))))
    
    ;; Sends a request to the server to find automatically words from the grid
    ;; and get find out how many points computer would have got.
    (defun get-computers-points ()
      (chain (chain ((chain $ ajax) (create type "post" 
    				     url "computer-score"
    				     data (create grid-string *grid-string*)))
    		    (done (lambda (results)
			    (setf result-array (chain *json* (parse results)))
    			    (setf *computers-points* (chain result-array (shift)))
    			    (setf *computers-words* result-array)
			    (chain ($ "#btnEndGame") (attr "disabled" nil)))))))

    ;; Disables the Boggle game in such a way that keypress and mouse click events
    ;; won't work. TODO: finish this function, not all handlers are off.
    (defun disable-grid ()
      (chain (chain ($ ".dBoggle") (remove-class "dBoggle")) (add-class "boggleDisabled"))      
      (chain ($ ".boggleControl") (attr "disabled" "disabled"))
      ($$$ ("#btnEndGame" (attr "disabled" "disabled")))
      ($$$ (document (off "keypress"))))

    ;; Deals with the events happening in the end of the game.
    (defun handle-game-end ()
      (clear-grid)
      (disable-grid)
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
    
      ;; (chain ((chain (chain ($ ".boggleDisabled") filter))
      ;; 	      (chain (chain (lambda()
      ;; 			      ((let ((data-x ($$$ (this (data "x"))))
      ;; 				    (data-y ($$$ (this (data "y")))))
      ;; 				(= (data-x (1- x)))))))))))

    ;; If letter is pressed, marking possible sites for the next character.
    ;; If only one possible place for the character is found, selecting it as 
    ;; the next character to the word.
    (defun letter-pressed (keycode)
      (let ((character (chain -string (from-char-code keycode)))
	    (found-tiles (list)))
	($$ (".dBoggle" each)
	  (cond ((equal ((chain (chain ($ this) (text)) to-lower-case)) character)
		 ($$$ (this (add-class "bogglePossible")))
		 (setf found-tiles (append found-tiles (@ ($ this)))))))
	(case (length found-tiles)
	  (0 nil)
	  ;; If just one applicable tile found, selecting it as the next letter.
	  (1 (tile-selected (getprop found-tiles 0)))
	  ;; If many possible tile-paths are found, getting their adjacent
	  ;; possible tiles.
	  (otherwise "many tiles found"))))

    (defun boggle-click-handler()
      ($$$ (document 
	    (keypress
	     (lambda (e)
	       (let ((clicked-key (@ e which)))
		 (cond
		   ;; Triggering word check if pressed space or enter.
		   ((or (= clicked-key 32) (= clicked-key 13))
		    ($$$ ("#btnCheckWord" (trigger "click"))))
		   ;; Getting letters ä and ö.
		   ((or (= clicked-key 228) (= clicked-key 246)
			(and (>= clicked-key 97) (<= clicked-key 122)))
		    (letter-pressed clicked-key))))))))			 		     		     	
      ;; Handling clicking on a letter with the left mouse key,
      ;; or sending the word for checking with other mouse keys.
      ($$$ (".dBoggle"
	     (mousedown
	      (lambda (event)
		(cond
		  ((= (chain event which) 1)
		   (let ((element (@ ($ this))))
		     (tile-selected element)))		 
		  ;; Checking word if not the leftmost mouse button clicked.
		  (t
		   ($$$ ("#btnCheckWord" (trigger "click"))))))))))

    ;; Handles confirming the selection of a tile.
    (defun tile-selected (element)
      (let ((selectedLetter ((@ element html)))
	    (is-not-selected ((@ element has-class) "dBoggle")))
	(cond (is-not-selected	       
	       ((@ ((@ element add-class) "boggleSelected") remove-class) "dBoggle")
	((@ ($ "#dGotLetters") append) selectedletter)
    (mark-un-selectable ((@ element data) "x") ((@ element data) "y"))))))

      (defun clear-grid ()
	((chain ((chain (chain ($ ".boggleSelected, .boggleDisabled") remove-class)) "boggleSelected boggleDisabled bogglePossible") add-class) "dBoggle"))

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
