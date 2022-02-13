import os
from flask import Flask, g
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def create_app():
    app = Flask(__name__, instance_relative_config=True)
    app.config['SECRET_KEY'] = 'dev'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqldb://user:pass@host/db'

    app.config.from_pyfile('config.py', silent=False)

    db.init_app(app)

    with app.app_context():
        g.db = db

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    from . import main, charts, api
    app.register_blueprint(main.bp)
    app.register_blueprint(charts.bp)
    app.register_blueprint(api.bp)

    return app
