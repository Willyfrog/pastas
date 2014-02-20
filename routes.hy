;(require hy.contrib.meth)
(import os)
(require methy)
(import model)
(import [flask [Flask request render-template abort]])
(setv main-dir (os.path.dirname (os.path.abspath __file__)))
(setv tmpl-dir (os.path.join main-dir "templates"))
(setv static-dir (os.path.join main-dir "static"))

(setv app (apply Flask ["__main__"] {"template_folder" tmpl-dir "static_folder" static-dir}))

(route get-index "/" []
       (str "Welcome to Pastas")) 

(route post-index "/list" []
       (let [[pasta-list (list-comp (string x) [x (model.get-some-pasta)])]]
         (print pasta-list)
         (.join ", " pasta-list)))


(route-with-methods  both-index "/new" ["GET" "POST"] []
                     (if (= request.method "GET")
                       (str "Hy to get world!")
                       (let [[user (get request.form "user")]
                             [key (get request.form "key")]
                             [content (get request.form "content")]]
                         (model.add-pasta user key content)
                         (str (model.get-pasta user key)))))

(route get-pasta "/c/<user>/<key>/" [user key]
       (let [[pasta (model.get-pasta user key)]]
         (print "received " user " & " key)
         (print "pasta value" pasta)
         (if (none? pasta)
           (abort 404)
           (apply render-template ["pasta.html"] {"pasta" (get pasta "code") "user" user "key" key}))))

(route get-pasta-with-sauce "/c/<user>/<key>/<lexer>/" [user key lexer]
       (let [[pasta (model.get-pasta user key)]]
         (print "received " user " & " key)
         (print "pasta value" pasta)
         (if (none? pasta)
           (abort 404)
           (apply render-template ["pasta-sauce.html"] {"pasta" (get (model.pasta-with-sauce pasta lexer) "code") "user" user "key" key}))))

