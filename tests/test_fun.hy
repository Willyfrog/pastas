(import [core :as c])

(setv sample-dict {"a" 1 "b" None "c" ""})

(defn test-get-or-default-ok []
  (assert (= (c.get-or-default sample-dict "a" 3) 1)))

(defn test-get-or-default-no-key []
  (assert (= (c.get-or-default sample-dict "j" 3) 3)))

(defn test-get-or-default-none-val []
  (assert (= (c.get-or-default sample-dict "b" 3) 3)))

(defn test-get-or-default-empty-string-val []
  (assert (= (c.get-or-default sample-dict "c" 3) 3)))
