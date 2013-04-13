(in-package #:heinonenco)

(defmacro standard-page ((&key title) &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"
	    :xml\:lang "fi" 
	    :lang "fi"
	    (:head 
	     (:meta :http-equiv "Content-Type" 
		    :content    "text/html;charset=utf-8")
	     (:title ,title)
	     (:link :type "text/css"
		    :rel "stylesheet"
		    :href "style.css")
	     (:script :type "text/javascript"
		      :src "scripts/jquery-1.8.3.min.js"))
	    (:body
	     (:header
	      (:h1 "Juho A. Heinosen kotisivut")
	      (:img :src "/img/lisplogo_128.png")
	      (:nav
	       (:ul
		(:li (:a :href "/" "Etusivu"))
		(:li (:a :href "js-simple" "Javascript-simppelit"))
		(:li (:a :href "js-canvas" "Javascript-canvas")))))
	     ,@body
	     (:script :type "text/javascript"
		      :src "scripts/code.js")))))
