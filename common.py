import os
from flask import Flask
import dataset

with open("config.json") as jfile:
    try:
        json_config = json.load(jfile)
    except:
        print ("no config loaded from config.json")


app = Flask("__main__")
app.secret_key = json_config.get("secretkey", "replacemeforsomethingunique")

db = dataset.connect(json_config.get("dbstring", "sqlite:///memory"))

PPP = json_config.get("PPP", 20)

lexer_list = json_config.get("lexer_list", [("python", "Python") ( "raw", "Raw") ( "clj", "Clojure") ( "php", "PHP") ( "html", "HTML")])
