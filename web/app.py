#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request, redirect, url_for

import psycopg2
import psycopg2.extras

# SGBD configs
DB_HOST = "127.0.0.1"
DB_USER = "postgres"
DB_DATABASE = DB_USER
DB_PASSWORD = "1234"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

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
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/category', methods=["POST", "GET"])
def list_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        if request.method == "POST":

            if request.form["button"] == "Remover":
                category = request.form["category_name"]
                #print(category)
                query = """
                    start transaction;
                    drop table if exists t;
                    with recursive remove_category(super_categoria, categoria) as (
                        select super_categoria, categoria from tem_outra t_o where t_o.super_categoria = %s or t_o.categoria = %s
                        union all
                        select t_o.super_categoria, t_o.categoria from tem_outra t_o
                            inner join remove_category rsc on rsc.categoria = t_o.super_categoria
                    )
                    select categoria into t from remove_category;
                    insert into t values(%s);
                    
                    delete from responsavel_por where nome_cat in (select * from t);
                    delete from tem_categoria where nome in (select * from t);
                    delete from tem_outra where super_categoria in (select categoria from t) or
                                                categoria in (select categoria from t);
                    delete from super_categoria where nome in (select categoria from t);
                    delete from categoria_simples where nome in (select categoria from t);
                    
                    delete from evento_reposicao er where er.ean in (
                        select ean from planograma plan where plan.ean = er.ean and ean in (
                            select ean from produto prod where prod.ean = plan.ean and cat in (
                                select nome from categoria cat where cat.nome in (select * from t)
                            )
                        )
                    );
                    delete from evento_reposicao er where er.ean in (
                        select ean from planograma plan where plan.ean = er.ean and ean in (
                            select ean from prateleira prat where prat.num_serie = plan.num_serie and nome in (
                                select nome from categoria cat where cat.nome in (select * from t)
                            )
                        )
                    );
                    delete from planograma plan where ean in (
                        select ean from produto prod where plan.ean = prod.ean and cat in (
                            select nome from categoria cat where cat.nome in (select * from t)
                        )
                    );
                    delete from planograma plan where num_serie in (
                        select num_serie from prateleira prat where
                                plan.num_serie = prat.num_serie and
                                plan.nro = prat.nro and
                                plan.fabricante = prat.fabricante and nome in (
                                --(nro, num_serie, fabricante) = (plan.nro, plan.num_serie, plan.fabricante) and nome in (
                            select nome from categoria cat where cat.nome in (select * from t)
                        )
                    );
                    delete from produto where cat in (select * from t);
                    delete from prateleira where nome in (select * from t);
                    delete from categoria where nome in (select * from t);
                    drop table if exists t;
                    commit;
                """
                #data = (category, category)
                cursor.execute(query, (category, category, category, ))
                return redirect(url_for('list_category', input_category=False))

            if request.form["button"] == "Adicionar":
                return redirect(url_for('list_category', input_category=True))

            if request.form["button"] == "Nova Categoria":
                new_category = request.form["new_category"]
                if new_category == "":
                    return redirect(url_for('list_category', input_category=True))
                query = "insert into categoria values (%s)"
                cursor.execute(query, (new_category,))
                return redirect(url_for('list_category', input_category=False))

        else:
            query = "SELECT * FROM categoria"
            cursor.execute(query)
            return render_template("category.html", cursor=cursor, input_category=request.args.get("input_category"))
    except Exception as e:
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/subcategories', methods=["POST", "GET"])
def subcategories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        #print(request.args)
        if request.method == "GET":
            category = request.args.get("nome_cat")
            query = """
            with recursive remove_category(super_categoria, categoria) as (
                select super_categoria, categoria from tem_outra t_o where t_o.super_categoria = %s or t_o.categoria = %s
                union all
                select t_o.super_categoria, t_o.categoria from tem_outra t_o
                    inner join remove_category rsc on rsc.categoria = t_o.super_categoria
            )
            select distinct categoria from remove_category where categoria != %s
            """
            cursor.execute(query, (category, category, category))
            return render_template("sub_categories.html", cursor=cursor, category=category, params=request.args)
    except Exception as e:
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/retailer', methods=["POST", "GET"])
def list_retailers():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        if request.method == 'POST':
            if request.form["button"] == "Remover":
                retailer = request.form["retailer_name"]
                query = """
                SELECT * INTO tb FROM retalhista WHERE nome = %s;
                DELETE FROM evento_reposicao WHERE tin IN (SELECT tin FROM tb);
                DELETE FROM responsavel_por WHERE tin IN (SELECT tin FROM tb);
                DELETE FROM retalhista WHERE nome IN (SELECT nome FROM tb);
                DROP TABLE tb;
                """
                cursor.execute(query, (retailer,))
                return redirect(url_for('list_retailers', input_retailer=False))
            
            if request.form["button"] == "Adicionar":
                return redirect(url_for('list_retailers', input_retailer=True))

            if request.form["button"] == "Novo retalhista":
                retailer = request.form["nome"]
                tin = request.form["tin"]
                if retailer == "" or tin == "":
                    return redirect(url_for('list_retailers', input_retailer=True))

                query = """
                INSERT INTO retalhista (nome, tin) VALUES (%s, %s);
                """
                cursor.execute(query, (retailer, tin))
                return redirect(url_for('list_retailers', input_retailer=False))
        else:
            query = "SELECT DISTINCT nome FROM retalhista;"
            cursor.execute(query)
            return render_template("retailer.html", cursor=cursor, input_retailer=request.args.get("input_retailer"))
    except Exception as e:
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/alter_retailer', methods=["POST", "GET"])
def alter_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        print(request.args)
        if(request.method == 'POST'):
            nome = request.form['nome']
            if request.form["button"] == "Remover":
                num_serie = request.form["num_serie"]
                fabricante = request.form["fabricante"]
                query = "DELETE FROM responsavel_por WHERE num_serie = %s AND fabricante = %s;"
                cursor.execute(query, (num_serie, fabricante))
            
            if request.form["button"] == "Nova responsabilidade":
                ivm = request.form["ivm"]
                categoria = request.form["category"]
                if ivm == "none" or categoria == "none":
                    return redirect(url_for('alter_retailer', name=nome))
                ivm = ivm.split('$')
                num_serie = ivm[0]
                fabricante = ivm[1]
    
                query = "SELECT tin FROM retalhista WHERE retalhista.nome = %s;"
                cursor.execute(query, (nome,))
                tin = cursor.fetchall()
                query = "INSERT INTO responsavel_por VALUES (%s, %s, %s, %s);"
                cursor.execute(query, (categoria, tin[0][0], num_serie, fabricante))

            return redirect(url_for('alter_retailer', name=nome))
        else:
            query = "SELECT nome_cat, num_serie, fabricante FROM responsavel_por NATURAL JOIN retalhista WHERE responsavel_por.tin IN (SELECT tin FROM retalhista WHERE nome = %s) ORDER BY nome_cat;"
            cursor.execute(query, (request.args.get("name"),))
            resp = cursor.fetchall()
            cursor.execute("SELECT * FROM IVM WHERE (num_serie, fabricante) NOT IN (SELECT num_serie, fabricante FROM responsavel_por);")
            ivms = cursor.fetchall()
            cursor.execute("SELECT nome FROM categoria ORDER BY nome;")
            categorias = cursor.fetchall()
            return render_template("alter_retailer.html", cursor=resp, ivms=ivms, categorias=categorias, params=request.args)
    except Exception as e:
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/ivm', methods=["POST", "GET"])
def list_ivms():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        if request.method == 'POST':
            num_serie = request.form["num_serie"]
            fabricante = request.form["fabricante"]
            query = "SELECT * FROM evento_reposicao WHERE num_serie = %s AND fabricante = %s;"
            cursor.execute(query, (num_serie, fabricante));
            ivm_query = cursor.fetchall()

            query = """SELECT tem_categoria.nome AS categoria, SUM(evento_reposicao.unidades) 
                       FROM produto JOIN tem_categoria ON produto.ean = tem_categoria.ean
                       JOIN evento_reposicao ON produto.ean = evento_reposicao.ean 
                       WHERE (num_serie, fabricante) = (%s, %s) 
                       GROUP BY tem_categoria.nome;"""
            cursor.execute(query, (num_serie, fabricante))
            ivm_query2 = cursor.fetchall()

            query = "SELECT DISTINCT * FROM ivm ORDER BY num_serie;"
            cursor.execute(query)
            return render_template('ivm.html', cursor=cursor, num_serie=num_serie, fabricante=fabricante, ivm_query=ivm_query, ivm_query2=ivm_query2)
        else:
            query = "SELECT DISTINCT * FROM ivm ORDER BY num_serie;"
            cursor.execute(query)
            return render_template("ivm.html", cursor=cursor)
    except Exception as e:
        return render_template("error.html", error_message=e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


CGIHandler().run(app)
