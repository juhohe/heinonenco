(in-package :heinonenco)

;;(defparameter *voikko* (voikko:initialize))

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
	   (:button :id "btnEndGame" :disabled t  "Lopeta peli etuajassa")

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
  

  (clsql:disconnect :database "scores.db"))

(defun controller-check-word ()
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (setf (header-out "score") (stringify (check-word-score (post-parameter "triedWord")))))))

(defun controller-computer-score ()
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (let ((computer-results
		(check-computer-score 
		 (format nil "~(~a~)" (post-parameter "gridString")))))

	   (setf (header-out "score") 
		 (format nil "[~{\"~a\"~^, ~}]" computer-results))))))
			 ;;(stringify computer-results))))))

(defun check-computer-score (grid-as-string)
  (check-multiple-words 
   (remove-duplicates (find-words-automatically grid-as-string) :test #'equal)))

(defun check-multiple-words (words-to-check)  
  (let ((accepted-words '())
	(total-score 0))    
    (loop for word in words-to-check
       do
	 (let ((score (check-word-score word)))
	   (cond ((> score 0)
		  (incf total-score score)
		  (push word accepted-words)))))
    (append (list total-score) accepted-words)))
		

;;  (loop for word in words-to-check
     ;;sum (check-word-score word)))

(defun check-word-score (word-to-check)
  (let ((analyses (voikko:with-instance (i)
  		    (voikko:analyze i word-to-check))))

;;    (break)
;;  (let ((analyses (voikko:analyze *voikko* word-to-check)))
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
	 (and 
	  (null (cdr (assoc "KYSYMYSLIITE" el :test #'string=)))
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
	    (null (cdr (assoc "POSSESSIVE" el :test #'string=)))))))

	 return el))

(defun get-free-spots (grid i j reserved-spots)
  (let ((dimension-x (array-dimension grid 0))
	(dimension-y (array-dimension grid 1))
	(free-spots '()))
    ;; (loop for a in (list (1- i) i (1+ i)) do
    ;; 	 (loop for b in (list (1- j) j (1+ j))	      

    (loop for a from (1- i) upto (1+ i) do
	 (loop for b from (1- j) upto (1+ j)
	    when (and (>= a 0) (< a dimension-x)
		      (>= b 0) (< b dimension-y)
		      (null (member (cons a b) reserved-spots :test #'equal)))
	      do (push (cons a b) free-spots)))
    free-spots))
	      
	    ;;collect (cons a b)))
	 
;;       do (push (cons a b) free-spots)))
;;  free-spots)

;;collect (cons i j)))))
           
;; This function checks for two-letter start of a word.
(defun impossible-word-start-p (word)
  (or   
   (cl-ppcre:scan "^([aou][yäö]|[yäö][aou])" word)
   (cl-ppcre:scan "^[bdgkt](?![rl])" word)))
    

  ;; (let ((front-vowels '(#\a #\o #\u))
  ;; 	(back-vowels '(#\y #\ä #\ö))	
  ;; 	(word-as-array (split-string-to-char-list word))
  ;; 	(stops '(#\b #\d #\g #\k #\t))
  ;; 	(liquids '(#\l #\r))
  ;; 	(char1 (char word 0))
  ;; 	(char2 (char word 1)))
  ;;   (or
     
  ;;    (and 
  ;;     (not (find char2 *vowels*))
  ;;     (not (find char1 *vowels*))
  ;;     (or
  ;;      (not (find char1 stops))
  ;;      (and
  ;; 	(find char1 stops)
  ;; 	(not (find char2 liquids)))))
     

  ;;    (and 
  ;;     (some (lambda (c)
  ;; 	      (find c front-vowels))
  ;; 	    word-as-array)
  ;;     (some (lambda (c)
  ;; 	      (find c back-vowels))
  ;; 	    word-as-array)))))

(defun is-consonant-p (letter)
  (find letter *consonants*))

(defun possible-word-p (last-letter word)
   (and 
    (find last-letter '(#\a #\e #\i #\o #\u #\y #\ä #\ö #\l #\n #\r #\s #\t))
    (some #'is-consonant-p (split-string-to-char-list word))
    ;; Rejecting words with five-letter-long and longer vowel clusters. 
    (null (cl-ppcre:scan "([aeiouyäö]{5}|[bdghjklmnpqrstv]{5})" word))))

;;(cl-ppcre:scan "([aeiouyäö]{5}|[bdghjklmnpqrstv]{5})" "srtgaaaae")



(defun get-possible-words (grid i j reserved-spots letters-this-far)  
;;  (break)
;;  (print "here")
  (let ((current-letter (aref grid i j))
	(free-spots '()))
;;	(found-words '()))

    (if (not (member (cons i j) reserved-spots :test #'equal))
	(push (cons i j) reserved-spots))

;;    (print letters-this-far)
;;    (break)
    (setf free-spots (get-free-spots grid i j reserved-spots))

    ;; Concatenating the new letter to this far got letters.
    (setf letters-this-far 
	  (concatenate 'string letters-this-far (string current-letter)))

     ;; stopping to five letters words for testing.
     (case (length letters-this-far)
       (7 (setf free-spots nil))
       (2 (and 
	   (impossible-word-start-p letters-this-far)
	   (return-from get-possible-words nil))))
    
    ;; (print letters-this-far)
    ;; (break)
    ;; (if 
    ;;  (and
    ;;   (= (length letters-this-far) 2)
    ;;   (impossible-word-start letters-this-far)     


    (cond 
      ((null free-spots)
       ;; Return current word as a one-length list's item
       (if (possible-word-p current-letter letters-this-far)
	   (list letters-this-far)
	   '()))
      (t 	
       (let ((found-words 
	      (loop for coordinate in free-spots
		 append	       
		   (get-possible-words 
		    grid
		    (car coordinate)
		    (cdr coordinate)
		    reserved-spots
		    letters-this-far))))
	 (if (and (> (length letters-this-far) 2)
		  (possible-word-p current-letter letters-this-far))
	     (push letters-this-far found-words))
	 found-words)))))
   
(defun split-string-to-char-list (string-to-split)
  (loop for i from 0 upto (1- (length string-to-split))
     collect (char string-to-split i)))

(defun split-string-to-groups (string-to-split group-length)
  (let ((char-list (split-string-to-char-list string-to-split)))   
    (loop for i from 0 upto (1- (length char-list)) by group-length
       collect (subseq char-list i (+ i group-length)))))

(defun create-letter-grid (grid-as-string &optional (x 4) (y 4))
  (make-array (list x y) :initial-contents (split-string-to-groups grid-as-string x)))

(defun find-words-automatically (grid-as-string &optional (x 4) (y 4))
  (let ((grid (create-letter-grid grid-as-string x y)))
    (loop for i from 0 upto (1- (array-dimension grid 0)) append
	 (loop for j from 0 upto (1- (array-dimension grid 1)) append
	      (get-possible-words grid i j '() "")))))


;; the variables *Rs* and *G* are just for testing.
(defparameter *rs* "oupihäeufutylärs")
(defparameter *g* (create-letter-grid *rs*))

(defparameter *vowels* (loop for char across "aeiouyäö" collect char))
(defparameter *consonants* (loop for char across "bdfghjklmnpqrstvyäö" collect char))
