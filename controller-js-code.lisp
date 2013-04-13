(in-package #:heinonenco)

(defun controller-js-code ()
  (ps ((@ ($ document) ready)
       (lambda ()
	 ((@ ($ "#btnTest") click)
	  (lambda ()
	    (alert "moro")))))))
