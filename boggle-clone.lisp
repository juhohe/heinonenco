(in-package :heinonenco)

(defun get-formatted-time-from-universal-time (timestamp)
  (if (not (numberp timestamp))
      (setf timestamp (parse-integer timestamp)))

  (multiple-value-bind
	(second minute hour date month year day-of-week dst-p tz)
      (decode-universal-time timestamp)
    (format t "~d.~d.~d ~d:~2,'0d:~2,'0d"
	    date
	    month
	    year
	    hour
	    minute
	    second)))

(defun controller-boggle-clone ()
  ;; Open the store where our data is stored

  (standard-page (:title "Sanapeli" :page-scripts (:script :type "text/javascript" :src "scripts/boggle-clone.js"))
    (:article
     (:h1 "Sanapeli")
     (:div :id "dWordGameControls"
           (:button :id "btnCheckWord" :class "boggleControl" :style "display: inline"
                    "Tarkista sana")
	   (:button :id "btnClearWord" :class "boggleControl"  "Tyhjennä valinta")
	   (:button :id "btnEndGame" "Lopeta peli etuajassa")

	   (:button :id "btnStartOver" :class "boggleControl" "Aloita uusi peli")
	   (:br)
	   (:span :id "dGotLettersLabel" :style "display:inline;" "Valitut kirjaimet: ")
	   (:div :id "dGotLetters" :style "display:inline-block;"))
     
     (:div :id "dGameGrid"

	   (:span :id "lblTimeLeft" "aikaa jäljellä")
	   (:span :id "sTimeLeft" :style "display:block;" "3:00")
	   (:table :id "tblBoggle"
		   (loop for i from 0 to 3 
		      do
			(htm (:tr
			      (loop for j from 0 to 3 
				 do
				   (htm 
				    (:td :data-x j :data-y i :class "dBoggle boggleTile")))))))
	   
	   (:br)

	   (:span :id "sFoundWordsLabel" :style "display:inline;"  "Löydetyt sanat: ")
	   (:span :id "sFoundWords" :style "display:inline; font-weight: Bold;")      
	   (:span :id "sPointsLabel" :style "display:inline;"
		  "Pisteet: ")
	   (:span :id "sPoints" "0"))

     (:div :id "dRightSide"
	   (:div :id "dInstructions"
		 (:h2 "Peliohjeet")
		 (:p "Pelissä on tavoitteena kerätä mahdollisimman paljon sanoja. Sanoja kerätään siten, että valitaan hiirellä napauttamalla vierekkäin sijaitsevia kirjaimia ja täten muodostetaan kirjaimista sanoja. Sana lähetetään tarkistettavaksi painamalla hiiren kakkos- tai kolmospainiketta tai klikkaamalla \"Tarkista sana\"-painiketta.")

		 (:p "Sanojen pituuden pitää olla vähintään 3 kirjainta. 3 ja 4 kirjaimen pituisista sanoista saa yhden pisteen, sitä pitemmistä sanoista saa yhden lisäpisteen jokaisesta neljän kirjaimen jälkeen tulevasta kirjaimesta. Verbeistä hyväksytään vain persoonattomat muodot. Nomineista (esim. pronomineista ja substantiiveista) hyväksytään yksikön ja monikon nominatiivit. Erisnimiä ei hyväksytä. Useimmat partikkelit hyväksytään. Huudahdussanoja (esim. \"seis\" ja \"morjens\") ei hyväksytä."))
	   
	   (:div :id "dHighScores"
		 (:h2 "Parhaat tulokset")
		 (:table :id "tblHighScores"
			 (:tr
			  (:th)
			  (:th "Nimi")
			  (:th "Pisteet")
			  (:th "Pisin sana")
			  (:th "Ajankohta"))
			 (let ((position 1))
			   (loop for score-item in (get-10-highest-scores) do
				(htm (:tr		      		      
				      (:td (str (stringify position ".")))
				      (:td (str (first score-item)))
				      (:td 
				       :id (if (= position 10) "tdTenthScore" "")
				       ;;					   (htm :id "tdTenthScore"))
				       (str (second score-item)))
				      (:td (str (third score-item)))
				      (:td (str (get-formatted-time-from-universal-time (car (last score-item)))))))
				
				

				(setq position (1+ position))				
				)			   
			   )))

	   (:div :id "dialogScore" :style "display:none;"
		 (:span :id "sDialogScore")
		 (:button :id "btnOk" "OK.")	   
		 (:div :id "dGetNameForHighScore" :style "display:none;"	       
					;		 (:form :action "save-high-score" :method "post"
		       (:p "Onneksi olkoon! Pääsit kunniatauluun. Jos annat nimesi, tallennetaan tuloksesi top 10 -listaan.")
		       (:label :for "player-name" "Nimi: ")
		       (:input :type "text" :name "player-name")
		       (:button :id "btnSaveHighScore" "OK")))))))
;; (:input :type "text" :name "longest-word"
;; 	:style "display: none;")
;; (:input :type "text" :name "points"
;; 	:style "display: none;")
;; (:input :type "submit" :id "btnSaveHighScore")))))))

(defun controller-save-high-score ()
  ;;  (break)
  ;; (with-open-file (stream  (merge-pathnames *application-path* "test.txt") :direction :output :if-exists :supersede)
  ;; (format stream (post-parameter "player-name")))
  ;; (signal (post-parameter "points"))
  ;; (signal (post-parameter "longestWord"))
  ;; (signal (post-parameter "playerName"))


  ;;(break)
  
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (save-high-score (post-parameter "points")
			  (post-parameter "longestWord")
			  (post-parameter "playerName")))))

(defun save-high-score (points longest-word player-name)
  (or (clsql:connected-databases)
      (clsql:connect "scores.db" :database-type :sqlite3))
  ;; (defparameter new-id (1+ (or (car (clsql:select [max [id]] :from [high-score]	
  ;; 					   :flatp t))0)))

  (defparameter new-id (1+ (or (car (clsql:query "select max(id) from high_score" :flatp t)) 0)))

  (defparameter row-timestamp (get-universal-time))
  
  (defparameter value-list (list new-id player-name points longest-word row-timestamp))

  (clsql:execute-command (format nil "insert into high_score (id, player_name, points, longest_word, timestamp) values (~d, '~a', ~d, '~a', '~a')" new-id player-name points longest-word row-timestamp))
  
  ;; (clsql:insert-records :into [high-score]
  ;; 			:attributes '(id player_name points longest_word timestamp)
  ;; 			:values value-list)

					;(timestamp (get-universal-time)))

  

  ;; (signal points)
  ;; (signal longest-word)
  ;; (signal new-id)
  ;; (break)

  ;; (clsql:insert-records :into [high-score]
  ;; 			  :attributes '([id] [points] [player-name] [longest-word] [timestamp])
  ;; 			  :values '(5 points player-name longest-word timestamp)))
  (clsql:disconnect :database "scores.db"))

(defun controller-check-word ()
  (cond ((eq (hunchentoot:request-method*) :POST)	
	 (setf (header-out "score") (string (check-word-score (post-parameter "triedWord")))))))

(defun check-word-score (word-to-check)
  (defparameter *voikko* (voikko:initialize))
  ;; (let ((analyses (voikko:with-instance (i)
  ;; 		    (voikko:analyze i word-to-check))))
  (let ((analyses (voikko:analyze *voikko* word-to-check)))
    (if (is-word-accepted analyses)
	(cond ((equal 3 (length word-to-check))
	       1)
	      ((equal 4 (length word-to-check))
	       1)
	      (t
	       (- (length word-to-check) 3)))
	0)))

(defun is-word-accepted (analyses)
  (loop for el in analyses when		    
       (let ((word-class (cdr (assoc "CLASS" el :test #'string=))))
	 (or	       
	  ;; particles
	  (equal word-class "suhdesana")
	  (equal word-class "seikkasana")
	  (equal word-class "sidesana")
	  
	  ;; verbs (only non-personal verb forms are accepted
	  (and (equal word-class "teonsana")
	       (null (cdr (assoc "PERSON" el :test #'string=))))	
	  ;; nouns, adjectives, and pronouns
	  (and
	   ;; excluding proper nouns ("erisnimet" in Finnish)
	   (not (equal (subseq word-class (- (length word-class) 4)) "nimi"))
	   (equal (cdr (assoc "SIJAMUOTO" el :test #'string=)) "nimento")
	   (null (cdr (assoc "FOCUS" el :test #'string=)))	 
	   (null (cdr (assoc "POSSESSIVE" el :test #'string=))))))
     return el))

(defun get-free-spots (grid i j reserved-spots)
  (let ((dimension-x (array-dimension grid 0))
	(dimension-y (array-dimension grid 1))
	(free-spots '()))
    (loop for a in (list (1- i) i (1+ i)) do
	 (loop for b in (list (1- j) j (1+ j))	      
	    when (and (>= a 0) (< a dimension-x)
		      (>= b 0) (< b dimension-y)
		      (null (member (cons a b) reserved-spots :test #'equal)))
;;		      (aref grid a b))

	      do (push (cons a b) free-spots)))
    free-spots))

;;collect (cons i j)))))
           
  
(defun get-possible-words (grid i j reserved-spots letters-this-far)  
  ;;(print (aref grid i j))
  (let ((current-letter (aref grid i j))
	(combinated-words '())      
	(free-spots '()));; (get-free-spots grid i j)))  
    ;; marking the used letter position.
;;    (setf (aref grid i j) nil)

    (if (not (member (cons i j) reserved-spots :test #'equal))
	(push (cons i j) reserved-spots))
    ;; (print "moi")
    ;; (print reserved-spots)
    (setf free-spots (get-free-spots grid i j reserved-spots))

    ;; Concatenating the new letter to this far got letters.

    (setf letters-this-far 
	  (concatenate 'string letters-this-far (string current-letter)))
    
    (cond 
      ((null free-spots)
;;       (print "moi")
;;       (break)
       (setf combinated-words (list letters-this-far)))
;;       (print combinated-words))
      (t (loop for coordinate in free-spots do
;;	      (break)
	      (setf combinated-words 
		    (append combinated-words (get-possible-words
					      grid
					      (car coordinate)
					      (cdr coordinate)
					      reserved-spots
					      letters-this-far))))))

    combinated-words))
   
(defun split-string-to-char-list (string-to-split)
  (loop for i from 0 upto (1- (length string-to-split))
     collect (char string-to-split i)))

(defun split-string-to-groups-of-four (string-to-split)
  (let ((char-list (split-string-to-char-list string-to-split)))   
    (loop for i from 0 upto (1- (length char-list)) by 4
       collect (subseq char-list i (+ i 4)))))

(defun create-letter-grid (grid-as-string)
  (make-array '(4 4) :initial-contents (split-string-to-groups-of-four grid-as-string)))

(defun find-words-automatically (grid-as-string)
  (let ((grid (create-letter-grid grid-as-string))
	(found-words '()))
    (loop for i from 0 upto 3 do
	 (loop for j from 0 upto 3 do
	      (setf found-words 
		    (append found-words (get-possible-words grid i j '())))))
    found-words))


;; the variables *Rs* and *G* are just for testing.
(defparameter *rs* "oupihäeufutylärs")
(defparameter *g* (create-letter-grid *rs*))
