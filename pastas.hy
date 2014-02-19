(import datasets)

(import [flask [Flask]])

(require hy.contrib.meth)

(setv db (dataset.connect "sqlite:///:memory:")) ;; bb.dd. en memoria
(setv app (Flask "__main__"))

(route get-index "/" []
  (str "Welcome to Pastas"))

(post-route post-index "/post" []
  (str "Hy post world!"))

(route-with-methods both-index "/both" ["GET" "POST"] []
  (str "Hy to both worlds!"))

(apply app.run [] {"port" 8080})
