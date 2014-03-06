(import os
        [flask [Flask]]
        dataset)

;; flask
(setv main-dir (os.path.dirname (os.path.abspath __file__)))
(setv tmpl-dir (os.path.join main-dir "templates"))
(setv static-dir (os.path.join main-dir "static"))
(setv secret-key "replacemeforsomethingunique")

(setv app (apply Flask ["__main__"] {"template_folder" tmpl-dir "static_folder" static-dir}))
(setv app.secret_key secret-key)

;; db
(setv db (dataset.connect "sqlite:///pastas.db")) ;; bb.dd. en memoria

(defn get-or-default [col key &optional [default-value None]]
  (let [[val  
           (try
            (get col key)
            (except [e [KeyError IndexError]]
              default-value))]]
    (if (or (none? val) (empty? val))
      default-value
      val)))

(setv lexer-list [(, "python" "Python") (, "raw" "Raw") (, "clj" "Clojure") (, "php" "PHP") (, "html" "HTML")])
