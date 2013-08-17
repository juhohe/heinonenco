(in-package :heinonenco)

(defparameter *cases*
  ;; Maybe "akkusatiivi" should be removed? Should I follow ISK conventions???
  '("nominatiivi"

    ;;"akkusatiivi" 

    "genetiivi" "partitiivi" "essiivi" "translatiivi" "inessiivi" "illatiivi" "elatiivi" "adessiivi" "allatiivi" "ablatiivi" "abessiivi" "instruktiivi" "komitatiivi"))

(defun remove-nth (list n)
  (remove-if (constantly t) list :start n :end (1+ n)))

(defclass word-object ()
  ((base-form
    :initarg :base-form)
   (inflection-type
    :initarg :inflection-type)
   (consonant-gradation
    :initarg :consonant-gradation
    :initform "")
   (grammatical-case
    :initarg :grammatical-case
    :initform "")))  

(defun create-word-object (word-data) 
  (let ((word-data-part (car word-data))
	(base-form "")
	(inflection-type 0)
	(consonant-gradation "")
	(grammatical-case (cdr word-data)))

    (loop for el in (xtree:all-childs word-data-part) do
	 (cond ((equal (xtree:local-name el) "s")
		(setf base-form (xtree:text-content el)))
	       ((equal (xtree:local-name el) "t")
		(loop for sub-el in (xtree:all-childs el) do
		     (cond ((equal (xtree:local-name sub-el) "tn")
			    (setf inflection-type 
				  (parse-integer (xtree:text-content sub-el))))
			   ((equal (xtree:local-name sub-el) "av")
			    (setf consonant-gradation (xtree:text-content sub-el))))))))

    (make-instance 'word-object 
		   :base-form base-form
		   :inflection-type inflection-type
		   :consonant-gradation consonant-gradation
		   :grammatical-case grammatical-case)))

;; This function returned originally 29365 word data items. Maybe that's unnecessary much, especially if it takes a lot of memory (only 14 of them are used actually)??
(defun get-words-data ()
  (let ((elements (xtree:all-childs (xtree:root (xtree:parse #p"/home/juhohe/Documents/SharedSection/src/lisp/heinonenco/kotus-sanalista_v1/kotus-sanalista_v1.xml")))))

    (setf elements (loop for el in elements		     		      
		      when (filter-to-only-simple-nouns el) collect el))))
      
(defun filter-to-only-simple-nouns (word-item)
  (and (equal (xtree:local-name word-item) "st")
       (let ((t-node (xtree:find-node (xtree:first-child word-item) (xtree:node-filter :local-name "t"))))
	 (and t-node
	      (let ((tn-node (xtree:find-node (xtree:first-child t-node) (xtree:node-filter :local-name "tn"))))
		(and tn-node
		     (let ((inflection-number (parse-integer (xtree:text-content tn-node) :junk-allowed t)))
		       (and inflection-number
			    (>= inflection-number 1)
			    (<= inflection-number 51)))))))))

(defparameter *simple-nouns* 
  (let ((words-data (get-words-data))
	(selected-words '()))
    ;; Getting 14 words to every case in Finnish. The number of cases is
    ;; however, not very clear. Maybe cases prolative and excessive should also
    ;; be dealt with?
    (loop for i from 1 to 14 do	 
	 (push 
	   (nth (random (length words-data)) words-data) selected-words))

    (mapcar #'create-word-object (pairlis selected-words *cases*))))
       
;;    (mapcar #'create-word-object (pairlis selected-words *cases*))))

(defun controller-grammatical-case-game ()
  (standard-page (:title "Sijamuotopeli"); :page-scripts (:script :type "text/javascript" :src "scripts/boggle-clone.js"))
    (:article
     (:h1 "Sijamuotopeli"))))







