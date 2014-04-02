import hy
import model
from common import app
from flask import request, render_template, flash, redirect, url_for, abort

@app.route("/")
def get_index():
    return render_template("home.html")

#TODO: add filters by user
#TODO: add pagination
@app.route("/list/")
def list_pastes():
    pasta_list = model.get_some_pasta()
    return render_template("pasta-list.html", pasta_list=pasta_list)

@app.route("/c/<user>/<key>/")
def get_pasta(user, key):
    pasta = model.get_pasta(user, key)
    if pasta is None:
        abort(404)
    else:
        return render_template("pasta.html", pasta=pasta["code"], user=user, key=key)

@app.route("/c/<user>/<key>/<lexer>/")
def get_pasta_with_sauce(user, key, lexer):
    pasta = model.get_pasta(user, key)
    if pasta is None:
        abort(404)
    else:
        with_sauce = model.pasta_with_sauce(pasta, lexer)
        return render_template("pasta-sauce.html", pasta=with_sauce["code"], user=user, key=key)
    

@app.route("/new/", methods=["GET", "POST"])
def create_new():
    app.logger.debug("Form keys: " + ", ".join(request.form.keys()))
    if request.method=="GET":
        return render_template("new.html", 
                        user=request.args.get("user", ""),
                        key=request.args.get("key", ""),
                        code=request.args.get("code", ""))
    else:
        user = request.form.get("user", "Anonymous")
        try:
            key =  request.form.get("key", model.gen_key(user))
        except KeyError as e:
            app.logger.error("Too many retries to generate a key")
            abort(500)
        code = request.form.get("code", "").strip()

        if (code is None or len(code) == 0):
            flash("No code to submit?")
            return redirect(url_for("create_new", user=user, key=key))
        elif model.is_used(user, key):
            flash("Select another key, that one has already been taken!")
            return redirect(url_for("create_new", user=user, key=key, code=code))
        else:
            model.add_pasta(user, key, code)
            return redirect(url_for("get_pasta", user=user, key=key))
