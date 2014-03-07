(import [model :as m])


(defn test_random_size []
  (assert (= 8 (len (m.-gen-random)))))

