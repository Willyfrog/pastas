(import sys)
(setv sys.executable "hy")

(import [routes [app]])

(apply app.run [] {"port" 8080 "extra_files" __file__ "debug" true})
