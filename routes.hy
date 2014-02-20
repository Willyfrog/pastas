;(require hy.contrib.meth)
(require methy)
(import model)
(import [flask [Flask request]])

(setv app (Flask "__main__"))

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
