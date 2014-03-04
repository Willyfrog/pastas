(import [string :as String]
        random
        re
        dataset
        [pygments [highlight]]
        [pygments.lexers [get-lexer-by-name]]
        [pygments.formatters [HtmlFormatter]]
        [core [db get-or-default]])


(setv pastas (get db "pastas"))

(defn add-pasta [user key code]
  (.insert pastas {"user" user "key" key "code" code}))

(defn check-key [user key]
  (none? (apply pastas.find-one [] {"user" user "key" key})))

(defn get-pasta [user key]
  (apply pastas.find-one [] {"user" user "key" key}))

(defn get-some-pasta [&optional [num-pastas 10]]
  (take num-pastas pastas))

(defn used-key? [user key]
  "Does the user already have that key?"
  (not (none? (get-pasta user key))))

(defn -gen-random []
  (.join "" (random.sample (+ String.letters String.digits) 8)))

(defn gen-key [user &optional [gen-fun -gen-random]]
  "Generate a valid & random key for the user"
  (setv key (gen-fun))
  (setv count 5)
  (while (and (> count 0) (used-key? user key))
    (setv key (gen-fun))
    (setv count (dec count)))
  (if (> count 0)
    key
    (raise KeyError)))

(defn pasta-with-sauce [pasta lexer]
  (let [[lex (get-lexer-by-name lexer)]]
    {"user" (get-or-default pasta "user")
     "key" (get-or-default pasta "key")
     "code" (highlight (get pasta "code") lex (apply HtmlFormatter [] {"linenos" true}))}))

