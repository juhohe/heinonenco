(in-package #:heinonenco)

(defun controller-css ()
  (setf (hunchentoot:content-type* hunchentoot:*reply*) "text/css")
  (setf css-lite:*indent-css* 4)
  (css-lite:css
    (("body")
     (:font-family "sans-serif"
		   :background-image "linear-gradient(0deg, rgb(70,110,50) 0%, rgb(230, 230, 230) 100%)"
		   :min-height "50em")
     (("section")
      (:width "80%" 
	      :height "90%"
	      :margin "0 auto 0 auto"
	      :padding "0em 2em 2em 2em"
	      :border-width "0.1em"
	      :border-style "solid" 
	      :border-radius "1em"
	      :background-color "rgb(255,255,255)")
      (("header")
       (:background-image "url(../img/lisplogo_128.png)"
			  :background-repeat "no-repeat"
			  :background-position "right"      
			  :margin "1em 0em 1em 0em"
			  :border-width "0.1em"
			  :border-style "solid"
			  :border-radius "1em")
       
       (("h1")
	(:font-size "200%" :text-align "left" :font-family "Comic Sans MS"
		    :font-style "italic"
		    :width "30%"
		    :border-style "solid"
		    :border-width "1px"
		    :padding "0.3em"
		    :margin "0.7em auto 0.2em 1em"
		    :border-radius "0.5em")))

       (("img")
	(:float "right"))
       (("nav")
	(:text-align "center"
		     :font-size "150%"
		     :width "65%"
		     :margin "0.7em auto 1em 1.3em"
		     :border-style "solid"
		     :border-width "1px"
		     :border-radius "0.5em"))
       (("nav ul li")
	(:display "inline" :margin "1em")
	((":hover")
	 (:color "rgb(240,240,240)"
		 :text-decoration "underline"
		 :background-image "linear-gradient(270deg, rgb(30, 100, 20) 0%, rgb(200, 220, 240) 240%)")))
       (("nav ul li a")
	(:text-decoration "None" :padding "1% 2% 1% 2%" :border-radius "0.5em"))))     
     (("article")
      (:border-width "0.1em"
		     :border-style "solid"
		     :border-radius "1em"
		     :padding "0em 1em 0em 1em"
		     :margin-bottom "1em"))  
     (("article h1")
      (:font-size "140%" :text-align "center")))))
