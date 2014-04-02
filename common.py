import os
from flask import Flask
import dataset

db = dataset.connect("sqlite:///pastas.db")
app = Flask("__main__")
app.secret_key = "replacemeforsomethingunique"
