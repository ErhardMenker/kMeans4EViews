%docs = ".\Docs\kmeans.pdf"
%url = "https://raw.githubusercontent.com/ErhardMenker/kMeans4EViews/master/update_info.xml"
%version = "1.0"

' a) add-in called in via code (go straight to the add-in & extract options or default per passed-in arguments)
addin(type="global", proc="kmeans", docs=%docs, url=%url,version={%version}) ".\kmeans.prg"
' b) add-in called in via GUI
addin(type="global", menu="k-means GUI", docs=%docs, url=%url,version={%version}) ".\kmeans_gui.prg"


