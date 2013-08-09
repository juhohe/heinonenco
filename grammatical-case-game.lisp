(in-package :heinonenco)

(defun controller-grammatical-case-game ()
  (standard-page (:title "Sijamuotopeli"); :page-scripts (:script :type "text/javascript" :src "scripts/boggle-clone.js"))
    (:article
     (:h1 "Sijamuotopeli"))))


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

;; This function returns 29365 word data items. Maybe that's unnecessary much, especially if it takes a lot of memory.
(defun get-words-data ()
;  (defvar elements (xtree:all-childs (xtree:root (xtree:parse #p"/home/juhohe/Documents/SharedSection/src/lisp/heinonenco/kotus-sanalista_v1/example.xml"))))

  ;; (defparameter elements (xtree:all-childs (xtree:root (xtree:parse #p"/home/juhohe/Documents/SharedSection/src/lisp/heinonenco/kotus-sanalista_v1/example.xml"))))

  (defparameter elements (xtree:all-childs (xtree:root (xtree:parse #p"/home/juhohe/Documents/SharedSection/src/lisp/heinonenco/kotus-sanalista_v1/kotus-sanalista_v1.xml"))))

;; 



;;  (break)

  (setf elements (loop for el in elements		     		      
		    when (filter-to-only-simple-nouns el) collect el))
; (xtree:node-filter :local-name "tn"

;(xtree:node-filter :local-name "tn")))

;(xtree:node-filter :local-name "tn")))

  ;;<tn>1-51</tn> is for nouns. Including only nouns. TODO: check if there also other passable words, maybe some "rare" inflections??
  (print (length elements)))

  ;; (loop for el in 

  ;;    when (equal (xtree:local-name el) "ts") collect el))
       
   
