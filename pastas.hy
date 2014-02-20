(import sys)
(setv sys.executable "hy")

(import [routes [app]])

(apply app.run [] {"host" "0.0.0.0" "port" 8080 "extra_files" __file__ "debug" true})
