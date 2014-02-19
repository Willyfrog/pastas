(import [flask [copy-current-request-context]])

(defmacro route-with-methods [name path methods params &rest code]
  "Same as route but with an extra methods array to specify HTTP methods"
  `(let [[deco (kwapply (.route app ~path)
                                    {"methods" ~methods})]]
                 (with-decorator deco
                   (with-decorator copy-current-request-context
                     (defn ~name ~params
                       (progn ~@code))))))

;; Some macro examples
(defmacro route [name path params &rest code]
  "Get request"
  `(route-with-methods ~name ~path ["GET"] ~params ~@code))
