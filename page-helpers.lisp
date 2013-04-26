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
		    :href "styles/style.css")
	     (:link :type "text/css"
		    :rel "stylesheet"
		    :href "styles/jquery-ui-1.10.2.custom.css"))
	    
	    (:body
	     (:section
	     (:header
	      (:h1 "Juho A. Heinosen kotisivut")
	      (:nav
	       (:ul
		(:li (:a :href "/" "Etusivu"))
		(:li (:a :href "js-simple" "Javascript-simppelit"))
		(:li (:a :href "js-canvas" "Javascript-canvas")))))
	     ,@body
	     (:script :type "text/javascript"
		      :src "scripts/jquery-1.9.1.js")
	     (:script :type "text/javascript"
		      :src "scripts/jquery-ui.js")
	     (:script :type "text/javascript"
		      :src "scripts/ui.datepicker-fi.js")
	     (:script :type "text/javascript"
		      :src "scripts/code.js"))))))
