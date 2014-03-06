;(require hy.contrib.meth)

(import [core [app get-or-default lexer-list]]
         model
         [flask [request render-template abort flash redirect url-for make-response]]
         [slugify [slugify]]
         )

(require methy)


(route get-index "/" []
       (render-template "home.html")) 

(defn show-pasta-list [pasta-list]
  (apply render-template ["pasta-list.html"] {"pasta_list" pasta-list "sauce_list" lexer-list}))

(route list-pastes "/list/" []
       (let [[pasta-list (model.get-some-pasta)]]
         (show-pasta-list pasta-list)))

(route user-pastes "/list/<user>/" [user]
       (let [[pasta-list (model.get-user-pasta user)]]
         (show-pasta-list pasta-list)))

(route get-pasta "/c/<user>/<key>/" [user key]
       (let [[pasta (model.get-pasta user key)]]
         (if (none? pasta)
           (abort 404)
           (apply render-template ["pasta.html"] {"pasta" (get pasta "code") "user" user "key" key}))))

(route-with-methods  create-new "/new/" ["GET" "POST"] []
                     (if (= request.method "GET")
                       (apply render-template ["new.html"] {"user" (slugify (get-or-default request.args "user" "")) 
                                                            "key" (slugify (get-or-default request.args "key" ""))
                                                            "code" (get-or-default request.args "code" "")})
                       
                       (let [[user (slugify (get-or-default request.form "user" "Anonymous"))]
                             [key (slugify (get-or-default request.form "key" (try 
                                                                                     (model.gen-key user)
                                                                                     (except [e KeyError]
                                                                                       (progn 
                                                                                        (app.logger.error "Too many retries to generate a key")
                                                                                        (abort 500))))))]
                             [code (.strip (get-or-default request.form "code" ""))]]
                         (app.logger.debug (% "user %s key %s code %s" (, user key code)))

                         (cond 
                          [(or (none? code) (empty? code))
                           (progn
                            (flash "No code to submit?")
                            (redirect (apply url-for ["create_new"] {"user" user "key" key})))]
                         [(.is_used_key model user key) 
                          (progn
                           (flash "Select another key, that one has already been taken!")
                           (redirect (apply url-for ["create_new"] {"user" user "key" key "code" code})))]
                         [True
                          (progn
                           (model.add-pasta user key code)
                           (redirect (apply url-for ["get_pasta"] {"user" user "key" key})))]))))

(route get-pasta-with-sauce "/c/<user>/<key>/<lexer>/" [user key lexer]
       (let [[pasta (model.get-pasta user key)]]
         (cond [(none? pasta) (abort 404)]
               [(= (.lower lexer) "raw") (let [[response (make-response (get (model.get-pasta user key) "code"))]]
                                           (setv (get response.headers "Content-Type") "text/plain; charset=utf-8")
                                           response)]
               [true (apply render-template ["pasta-sauce.html"] {"pasta" (get (model.pasta-with-sauce pasta lexer) "code") "user" user "key" key})])))

