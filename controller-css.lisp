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
	      :background-color "rgb(255,255,255)"
	      :min-width "70em")
      (("header")
       (:background-image "url(../img/lisplogo_128.png)"
			  :background-repeat "no-repeat"
			  :background-position "97%"      
			  :margin "1em 0em 1em 0em"
			  :border-width "0.1em"
			  :border-style "solid"
			  :border-radius "1em")
       
       (("h1")
	(:font-size "200%" :text-align "left" :font-family "Comic Sans MS"
		    :font-style "italic"
		    :width "30%"
		    :border-style "solid"
		    :border-color "rgb(0,0,0)"
		    :border-width "1px"
		    :padding "0.3em"
		    :margin "0.7em auto 0.2em 1em"
		    :border-radius "0.5em"
		    :padding-left "0.7em"))
       (("h1:hover")
	(:color "rgb(30, 150, 20)"
		:background-image "linear-gradient(270deg, rgb(70,110,50) 0%, rgb(230, 230, 230) 60%)"))
      (("img")
       (:float "right"))
      (("nav")
       (:text-align "center"
		    :font-size "150%"
		    :width "75%"
		    :margin "0.7em auto 1em 1.3em"
		    :border-style "solid"
		    :border-width "1px"
		    :border-radius "0.5em"))
      (("nav ul li")
       (:display "inline" :margin "1em")
       ((":hover")
	(:color "rgb(240,240,240)"
		:text-decoration "underline"
					;		 :background-image "linear-gradient(270deg, rgb(70,110,50) 0%, rgb(230, 230, 230) 100%)")))
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
     (:font-size "140%" :text-align "center")))
    
    ((".dWordGame")
     (:margin "0 auto 0 auto" :display "inline-block"))

    (("#dGameGrid")
     (:display "inline" :width "50%"))
    (("#dRightSide")
     (:display "inline-block"))
    
    ((".dBoggle, .boggleSelected, .boggleDisabled")
     (:height "3em" :width "3em" :border-style "solid" :border-width "2px" :display "inline-block" :padding "1em" :font-size "20pt"))
    ((".dBoggle:hover")
     (:cursor "pointer" :background-color "rgb(10, 30, 200)"))
    ((".boggleSelected")
     (:background-color "rgb(20, 220, 20)"))
    ((".boggleDisabled")
     (:background-color "rgb(200, 200, 200)"))
    (("button")
     (:cursor "pointer"))
    (("#btnStartOver")
     (:float "right" :margin-right "5%"))
    (("#tblHighScores")
     (:width "70%"))
    (("#tblHighScores th")
     (:text-align "left" :font-weight "Bold"))))
  
  




