(in-package #:heinonenco)

(setf *js-string-delimiter* #\")

(defun controller-js-code ()

  (ps 

					;context.fillRect(25, 25, 125, 125);
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
	       15 35 250 125)))
	((@ ($ "#btnTest") click)
	 (lambda ()
	   (alert "moro")))
	((@ ($ "#iDateTest") datepicker)))))))

					;var context = canvas.getContext("2d");
;;(ps (defvar *canvas* ((@ document getElementById)
					;				 "testCanvas")))

					;(ps (@ document write)
					;   ("moi"))
;;(ps (@ datepicker regional ["fi"]))

					;(ps ((@ document write)
					; (ps-html ((:a :href "#"
					;              :onclick (ps-inline (transport))) "link"))))



(ps (ps-html "disabled"))


(ps (setf (@ context fillStyle) "moi"))
