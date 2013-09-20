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

		       (:p "Onneksi olkoon! Pääsit kunniatauluun. Jos annat nimesi, tallennetaan tuloksesi top 10 -listaan.")
		       (:label :for "player-name" "Nimi: ")
		       (:input :type "text" :name "player-name")
		       (:button :id "btnSaveHighScore" "OK")))))))

(defun controller-save-high-score ()
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (save-high-score (post-parameter "points")
			  (post-parameter "longestWord")
			  (post-parameter "playerName")))))

(defun save-high-score (points longest-word player-name)
  (or (clsql:connected-databases)
      (clsql:connect "scores.db" :database-type :sqlite3))
  
  (let ((new-id (1+ (or (car (clsql:query "select max(id) from high_score" :flatp t)) 0)))
	(row-timestamp (get-universal-time)))
    
    (clsql:execute-command (format nil "insert into high_score (id, player_name, points, longest_word, timestamp) values (~d, '~a', ~d, '~a', '~a')" new-id player-name points longest-word row-timestamp))  
    (clsql:disconnect :database "scores.db")))

(defun controller-check-word ()
  (voikko:with-instance (i) (cond ((eq (hunchentoot:request-method*) :POST)
				   (setf (header-out "score") (stringify (check-word-score (post-parameter "triedWord") i)))))))

(defun controller-computer-score ()
  (cond ((eq (hunchentoot:request-method*) :POST)
	 (let ((computer-results
		(check-computer-score
		 (format nil "~(~a~)" (post-parameter "gridString")) nil)))
	   (setf (header-out "score") 
		 (format nil "[~{\"~a\"~^, ~}]" computer-results))))))

(defparameter *save-file-name* (merge-pathnames *application-path* "word-list.txt"))

(defun check-computer-score (grid-as-string &optional (save-file-name))
  "Finds words automatically from the grid string and computes score for them. Returns the score as the first item of the returned collection. Cdr of the list is the found words. If save-file-name is not nil, saving the word-list to a file with the path given in the parameter. TODO: test the file write better so that no threading issues will occur."
  (let ((word-list nil))
    (setf word-list 
	  (check-multiple-words
	   (find-words-automatically (string-downcase grid-as-string))))
    (when save-file-name
      (save-list-to-file-as-separate-strings save-file-name (cdr word-list)))
    word-list))

(defun save-list-to-file-as-separate-strings (file-name list-to-save)
  (with-open-file (stream file-name
			  :direction :output
			  :if-exists :append
			  :if-does-not-exist :create)
    (format stream "~{\"~a\"~^ ~}" list-to-save)))
   
(defun check-multiple-words (words-to-check)  
  (let ((accepted-words '())
	(total-score 0))
    (voikko:with-instance (i) 
      (loop for word in words-to-check
	 do
	   (let ((score (check-word-score word i)))
	     (cond ((> score 0)
		    (incf total-score score)
		    (push word accepted-words)))))
      (append (list total-score) accepted-words))))

(defun check-word-score (word-to-check voikko-instance)
  (let ((analyses (voikko:analyze voikko-instance word-to-check)))
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

(defun get-free-spots (coordinate grid-length reserved-spots)
  (let ((i (car coordinate))
	(j (cdr coordinate)))
    (loop for a from (1- i) upto (1+ i) append
	 (loop for b from (1- j) upto (1+ j)
	    when (and (>= a 0) (< a grid-length)
		      (>= b 0) (< b grid-length)
		     ;; (and (not (equal a i)) (not (equal b j)))
		      (null (member (cons a b) reserved-spots :test #'equal)))
	      collect (cons a b)))))
	                 
;; This function checks for two-letter start of a word.
(defun impossible-word-start-p (word)
  (or   
   (cl-ppcre:scan "([aou][yäö]|[yäö][aou])" word)
   (cl-ppcre:scan "^[bdgkpt](?![rl])" word)))

(defun possible-word-p (word)
  (and
   ;; Ensuring that the word has at least one consonant
   ;; and ends with an allowed letter.
   ;; TODO: rethink this, is it possible that a word accepted in this game
   ;; has its only consonant as the last letter of the word?
   (cl-ppcre:scan "[bdghjklmnprstv]" word)
   (cl-ppcre:scan "[aeiouyäölnrst]$" word)
   ;; Rejecting words with three-letter-long stop clusters and
   ;; six-letter-long consonant clusters.
   (null (cl-ppcre:scan "(^(.?[aou][^l]?[yäö]|.?[yäö][^l]?[aou]|[hjlmnrsv][bdfghjklmnprstv]|.?[fv][hst]|[bdgkt][bdfgjkmstv])|([bdgkt]{3}|[bdghjklmnpqrstv]{6})|([aou][^l]?[yäö]|[yäö][^l]?[aou])$)"
	  word))))

(defun get-possible-words (grid coordinate grid-length
			   reserved-spots letters-this-far
			   &optional (maximum-word-length 8))
  (labels ((get-possible-words-helper
	     (grid coordinate grid-length reserved-spots letters-this-far)
	   (let ((current-letter (aref grid 
				       (car coordinate)
				       (cdr coordinate)))
		 (free-spots nil))
	     (unless (find coordinate reserved-spots :test #'equal)
	       (setf reserved-spots (cons coordinate reserved-spots)))
	     
	     (setf letters-this-far
		   (concatenate 'string letters-this-far (string current-letter)))
	     
	     (cond
	       ((= (length letters-this-far) maximum-word-length)
		(return-from get-possible-words-helper 
		  (if (possible-word-p letters-this-far)
		      (list letters-this-far)))))

	     (setf free-spots
		   (get-free-spots coordinate
				   grid-length
				   reserved-spots))	    
	     
	     (unless free-spots
	       (return-from get-possible-words-helper
		 (if (possible-word-p letters-this-far)
		     (list letters-this-far))))
	     
	     (loop for spot in free-spots append
		  (append (get-possible-words-helper grid spot grid-length
					     reserved-spots 
					     letters-this-far) 
			  (if (and (> (length letters-this-far) 2)
				   (possible-word-p letters-this-far))
			      (list letters-this-far)))))))
  
    (get-possible-words-helper grid coordinate grid-length
			       reserved-spots letters-this-far)))
	       	       
(defun split-string-to-char-list (string-to-split)
  (loop for i from 0 upto (1- (length string-to-split))
     collect (char string-to-split i)))

(defun split-string-to-groups (string-to-split group-length)
  (let ((char-list (split-string-to-char-list string-to-split)))
    (loop for i from 0 upto (1- (length char-list)) by group-length
	 collect (subseq char-list i (+ i group-length)))))

(defun create-letter-grid (grid-as-string)
  (let ((grid-length (rationalize (sqrt (length grid-as-string)))))
    (when (integerp grid-length))
      (make-array (list grid-length grid-length) 
		  :initial-contents (split-string-to-groups 
				     grid-as-string grid-length))))

;; Grid as string must be a string of length whose square root is an integer.
(defun find-words-automatically (grid-as-string &optional (maximum-word-length 10))
  (let ((grid (create-letter-grid grid-as-string)))
    (when grid
      (remove-duplicates
       (loop for i from 0 upto (1- (array-dimension grid 0)) append
	    (loop for j from 0 upto (1- (array-dimension grid 1)) append
		 (get-possible-words grid (cons i j) (array-dimension grid 0) '() "" maximum-word-length))) :test #'equal))))
  
;; the variables *Rs* and *G* are just for testing.
(defparameter *s* "abcdefghi")
(defparameter *sg* (create-letter-grid *s*))
(defparameter *rs* "oupihäeufutylärs")
(defparameter *g* (create-letter-grid *rs*))
(defparameter *ts1* "limrtaekouaaiakr")

;;(defparameter *vowels* (loop for char across "aeiouyäö" collect char))
;;(defparameter *consonants* (loop for char across "bdfghjklmnpqrstvyäö" collect char))

;; (defun remove-nth (list n)
;;   (remove-if (constantly t) list :start n :end (1+ n)))

;; (define-modify-macro remove-nth-f (n) remove-nth "Remove the nth element")

;; (defmacro pop-nth (list n)
;;   (let ((n-var (gensym)))
;;     `(let ((,n-var ,n))
;;        (prog1 (nth ,n-var ,list)
;;          (remove-nth-f ,list ,n-var)))))

(defun get-1000-example-items (collection)
  "Returns 1000 random items from a collection. If the collection's size is smaller,
returning the whole list"
  (let ((collection-length (length collection)))    
    (if (<= collection-length 1000)
	collection
	(loop for i from 999 downto 0 
	   collect (nth (random collection-length) collection)))))

;;(defparameter *collected-words-hash-table* (get-found-words-hash-table))

(defun get-found-words-hash-table (&optional (file-path *save-file-name*))
  (with-open-file (stream file-path :direction :input)
    (let ((file-contents (slurp-stream4 stream)))
      (setf file-contents 
	    (remove-duplicates
	     (read-from-string
	      (concatenate 'string "(" file-contents ")")) :test #'equal))
      file-contents)))

;; http://www.ymeme.com/slurping-a-file-common-lisp-83.html
(defun slurp-stream4 (stream)
  (let ((seq (make-string (file-length stream))))
    (read-sequence seq stream)
    seq))


;; (defun fib (n)
;;   "Simple recursive Fibonacci number function"
;;   (if (< n 2)
;;     n
;;     (+ (fib (- n 1)) (fib (- n 2)))))

;; (defun fib-trec (n)
;;   "Tail-recursive Fibonacci number function"
;;   (labels ((calc-fib (n a b)
;;                      (if (= n 0)
;;                        a
;;                        (calc-fib (- n 1) b (+ a b)))))
;;     (calc-fib n 0 1)))
