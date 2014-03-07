(import os
        [flask [Flask]]
        dataset
        json)

(with [[jfile (open "config.json")]]
      (setv json-config (try (json.load jfile)
                             (except [e Exception]
                               (do (print e)
                                   (print "no config was loaded from config.json")
                                   {})))))
(print json-config)
(defn get-or-default [col key &optional [default-value None]]
  (let [[val  
           (try
            (get col key)
            (except [e [KeyError IndexError]]
              default-value))]]
    (if (or (none? val) (and (string? val) (empty? val)))
      default-value
      val)))

;; flask paths
(setv main-dir (os.path.dirname (os.path.abspath __file__)))
(setv tmpl-dir (os.path.join main-dir (get-or-default json-config "templates" "templates")))
(setv static-dir (os.path.join main-dir (get-or-default json-config "static" "static")))

(setv secret-key (get-or-default json-config "secretkey" "replacemeforsomethingunique"))

(setv app (apply Flask ["__main__"] {"template_folder" tmpl-dir "static_folder" static-dir}))
(setv app.secret_key secret-key)

;; db
(setv db (dataset.connect (get-or-default json-config "dbstring" "sqlite:///memory"))) ;; bb.dd. en memoria

;; pastas per page
(setv +PPP+ (get-or-default json-config "PPP" 20))

;; lexers
(setv lexer-list (get-or-default json-config "lexer-list" [(, "python" "Python") (, "raw" "Raw") (, "clj" "Clojure") (, "php" "PHP") (, "html" "HTML")]))
