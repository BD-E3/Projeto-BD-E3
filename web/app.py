#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request

import psycopg2
import psycopg2.extras

# SGBD configs
DB_HOST = "127.0.0.1"
DB_USER = "postgres"
DB_DATABASE = DB_USER
DB_PASSWORD = "password"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

app = Flask(__name__)


@app.route('/')
def list_accounts():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        # query = "SELECT * FROM categoria;"
        # cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route('/category')
def list_category_edit():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("category.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route('/retailer')
def list_retailers():
    dbConn = None
    cursor = None
    try:#balance?account_number={{ record[0] }}
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT DISTINCT nome FROM responsavel_por NATURAL JOIN retalhista WHERE responsavel_por.tin = retalhista.tin"
        cursor.execute(query)
        return render_template("retailer.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

"""
@app.route('/remove_retailer')
def list_category_edit():
    dbConn = None
    cursor = None
    try:#balance?account_number={{ record[0] }}
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT DISTINCT nome, nome_cat FROM responsavel_por NATURAL JOIN retalhista WHERE responsavel_por.tin = retalhista.tin ORDER BY nome;"
        cursor.execute(query)
        return render_template("retailer.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route('/alter_retailer')
def list_category_edit():
    dbConn = None
    cursor = None
    try:#balance?account_number={{ record[0] }}
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT DISTINCT nome, nome_cat FROM responsavel_por NATURAL JOIN retalhista WHERE responsavel_por.tin = retalhista.tin ORDER BY nome;"
        cursor.execute(query)
        return render_template("retailer.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()
"""

CGIHandler().run(app)