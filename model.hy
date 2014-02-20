(import dataset)
(import [pygments [highlight]])
(import [pygments.lexers [get-lexer-by-name]])
(import [pygments.formatters [HtmlFormatter]])

(setv db (dataset.connect "sqlite:///pastas.db")) ;; bb.dd. en memoria
(setv pastas (get db "pastas"))

(defn add-pasta [user key code]
  (.insert pastas {"user" user "key" key "code" code}))

(defn check-key [user key]
  (none? (apply pastas.find-one [] {"user" user "key" key})))

(defn get-pasta [user key]
  (apply pastas.find-one [] {"user" user "key" key}))

(defn get-some-pasta [&optional [num-pastas 10]]
  (take num-pastas pastas))

(defn pasta-with-sauce [pasta lexer]
  (let [[lex (get-lexer-by-name lexer)]]
    {"user" (get pasta "user") 
     "key" (get pasta "key")
     "code" (highlight (get pasta "code") lex (HtmlFormatter))}))
