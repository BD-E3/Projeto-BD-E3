#!/usr/bin/python3
import re
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request, redirect, url_for

import psycopg2
import psycopg2.extras

# SGBD configs
DB_HOST = "127.0.0.1"
DB_USER = "postgres"
DB_DATABASE = DB_USER
DB_PASSWORD = "pereirawp2002"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

@app.route('/')
def list_accounts():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
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

@app.route('/retailer', methods=["POST", "GET"])
def list_retailers():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        if(request.method == 'POST'):
            retailer = request.form["retailer_name"]
            query = """
            START TRANSACTION;
            SELECT * INTO t FROM retalhista WHERE nome=%s;
            DELETE FROM evento_reposicao WHERE tin IN (SELECT tin FROM t);
            DELETE FROM responsavel_por WHERE tin IN (SELECT tin FROM t);
            DELETE FROM retalhista WHERE nome IN (SELECT nome FROM t);
            DROP TABLE t;
            COMMIT;
            """
            cursor.execute(query,(retailer,))
            return redirect(url_for('list_retailers'))
        else:
            query = "SELECT DISTINCT nome FROM responsavel_por NATURAL JOIN retalhista WHERE responsavel_por.tin = retalhista.tin;"
            cursor.execute(query)
            return render_template("retailer.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route('/update_category')
def update_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        category = request.arg[1]
        print(category, 'aaaaaaaaaaaaaaaaaaaaaa')
        query = """
            with recursive remove_super_category(super_categoria, categoria) as ( 
                select super_categoria, categoria from tem_outra t_o 
                    where t_o.super_categoria = %s or t_o.categoria = %s 
                union all 
                select t_o.super_categoria, t_o.categoria from tem_outra t_o 
                    inner join remove_super_category rsc on rsc.categoria = t_o.super_categoria 
            ) 
            delete from tem_outra where super_categoria in (select categoria from remove_super_category) or 
                                categoria in (select categoria from remove_super_category);"""
        app.logger.info('teste')

        data = category
        cursor.execute(query, data)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


CGIHandler().run(app)

"""

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