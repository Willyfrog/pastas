import hy
import model
from common import app, lexer_list
from flask import request, render_template, flash, redirect, url_for, abort
from slugify import slugify


@app.route("/")
def get_index():
    return render_template("home.html")


def show_pasta_list(pasta_list):
    return render_template("pasta-list.html",
                           pasta_list=pasta_list,
                           sauce_list=lexer_list)


@app.route("/list/")
def list_pastes():
    return show_pasta_list(model.get_some_pasta())


@app.route("/list/<int:page>")
def list_pastes_page(page):
    """
    traverse pagination of results
    Arguments:
    - `page`:
    """
    return show_pasta_list(model.get_some_pasta(start_from=page))


@app.route("/list/<user>")
def user_pastes(user):
    """
    List pastes of a user
    Arguments:
    - `user`:
    """
    return show_pasta_list(model.get_user_pasta (user))

@app.route("/c/<user>/<key>/")
def get_pasta(user, key):
    pasta = model.get_pasta(user, key)
    if pasta is None:
        abort(404)
    else:
        return render_template("pasta.html",
                               pasta=pasta["code"], 
                               user=user,
                               key=key)

@app.route("/c/<user>/<key>/<lexer>/")
def get_pasta_with_sauce(user, key, lexer):
    pasta = model.get_pasta(user, key)
    if pasta is None:
        abort(404)

    with_sauce = model.pasta_with_sauce(pasta, lexer)
    return render_template("pasta-sauce.html", 
                           pasta=with_sauce["code"], 
                           user=user, 
                           key=key)
    

@app.route("/new/", methods=["GET", "POST"])
def create_new():
    app.logger.debug("Form keys: " + ", ".join(request.form.keys()))
    if request.method=="GET":
        return render_template("new.html", 
                               user=slugify(request.args.get("user", "")),
                               key=slugify(request.args.get("key", "")),
                               code=request.args.get("code", ""))
    else:
        user = slugify(request.form.get("user", "Anonymous"))
        try:
            key =  slugify(request.form.get("key", model.gen_key(user)))
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

@app.route("/c/<user>/<key>/<lexer>/")
def get_pasta_with_sauce(user, key, lexer):
    
