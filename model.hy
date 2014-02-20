(import dataset)

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
