;(require hy.contrib.meth)

(import [core [app get-or-default]]
         model
         [flask [request render-template abort flash redirect url-for]])

(require methy)


(route get-index "/" []
       (render-template "home.html")) 

(route list-pastes "/list/" []
       (let [[pasta-list (apply model.get-some-pasta)]]
         (apply render-template ["pasta-list.html"] {"pasta_list" pasta-list})))

(route get-pasta "/c/<user>/<key>/" [user key]
       (let [[pasta (model.get-pasta user key)]]
         (if (none? pasta)
           (abort 404)
           (apply render-template ["pasta.html"] {"pasta" (get pasta "code") "user" user "key" key}))))

(route-with-methods  create-new "/new/" ["GET" "POST"] []
                     (if (= request.method "GET")
                       (apply render-template ["new.html"] {"user" (get-or-default request.args "user" "") 
                                                            "key" (get-or-default request.args "key" "")
                                                            "code" (get-or-default request.args "code" "")})
                       
                       (let [[user (get-or-default request.form "user" "Anonymous")]
                             [key (get-or-default request.form "key" (try 
                                                                      (model.gen-key user)
                                                                      (except [e KeyError]
                                                                        (progn 
                                                                         (app.logger.error "Too many retries to generate a key")
                                                                         (abort 500)))))]
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
         (if (none? pasta)
           (abort 404)
           (apply render-template ["pasta-sauce.html"] {"pasta" (get (model.pasta-with-sauce pasta lexer) "code") "user" user "key" key}))))

