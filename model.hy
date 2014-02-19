(import [pastas [db]])

(setv pastas (get db "pastas"))

(defn add-pasta [user key code]
  (pastas.insert {"user" user "key" key "code" code}))

(defn get-pasta [user key]
  (apply pastas.find_one [] {"user" user "key" key}))

