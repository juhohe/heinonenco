(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

;; (defmacro document-ready (function-body)
;;   `(ps ((chain ($ document) ready) (lambda ()
;; 				    ( ,@function-body)))))

(defun controller-js-code ()
  (ps
    ((@ ($ document) ready)
     (lambda ()

       (defvar canvas ((@ document get-element-by-id)
		       "canvasTest"))

       (if (not (eq canvas nil)) 
	   (progn 
	     (defvar context ((@ canvas get-context)
			      "2d"))
	     (setf (@ context fill-style) "rgba(50, 120, 255, .5)")
	     ((@ context fill-rect)
	      15 35 250 125)
	     ))
       ((@ ($ "#btnTest") click)
	(lambda ()
	  (alert "moro")))

       ((@ ($ "#iDateTest") datepicker))))))

(ps (ps-html "disabled"))
