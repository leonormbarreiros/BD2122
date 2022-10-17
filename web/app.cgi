#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist195618"
DB_DATABASE = DB_USER
DB_PASSWORD = "vdnh8027"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)

@app.route('/')
def home():
    try:
        return render_template("index.html")
    except Exception as e:
        return render_template("erro.html", error_message=e) 

###########################

# a) Inserir e remover categorias e sub-categorias

@app.route('/categorias/')
def list_categories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query  = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categorias.html", cursor=cursor)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# a)1) Inserir categorias

@app.route('/categorias/nova_cat')
def new_category_form():
    try:
        return render_template("nova_categoria.html")
    except Exception as e:
        return render_template("erro.html", error_message=e) 

@app.route('/categorias/nova_cat/update', methods=["POST"])
def new_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome   = request.form["nome"]
        tipo   = request.form["tipo"]
        if tipo == "simples":
            query  = "START TRANSACTION; \
                      INSERT INTO categoria (nome) VALUES (%s); \
                      INSERT INTO categoria_simples (nome) VALUES (%s); \
                      COMMIT;"
        elif tipo == "super":
            query  = "START TRANSACTION; \
                      INSERT INTO categoria (nome) VALUES (%s); \
                      INSERT INTO super_categoria (nome) VALUES (%s); \
                      COMMIT;"
        data   = (nome, nome)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# a)2) Remover categorias

@app.route('/categorias/remo_cat')
def del_category_form():
    try:
        return render_template("remo_categoria.html", params=request.args)
    except Exception as e:
        return render_template("erro.html", error_message=e) 

@app.route('/categorias/remo_cat/update', methods=["POST"])
def del_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome   = request.form["nome"]
        query = "START TRANSACTION; \
                 DELETE FROM categoria_simples WHERE nome=(%s); \
                 DELETE FROM super_categoria WHERE nome=(%s); \
                 DELETE FROM categoria WHERE nome=(%s); \
                 COMMIT;"
        data   = (nome,nome,nome)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# a)3) Inserir sub-categorias

@app.route('/categorias/nova_subcat')
def new_sub_category_form():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM super_categoria;"
        cursor.execute(query)
        dbConn.commit()
        return render_template("nova_sub_categoria.html", cursor=cursor) 
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

@app.route('/categorias/nova_subcat/super')
def new_sub_category_super_form():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        dbConn.commit()
        return render_template("nova_sub_categoria_super.html", params=request.args, cursor=cursor) 
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

@app.route('/categorias/nova_subcat/super/sub/')
def new_sub_category_fim_form():
    try:
        return render_template("nova_sub_categoria_fim.html", params=request.args) 
    except Exception as e:
        return render_template("erro.html", error_message=e) 
        

@app.route('/categorias/nova_subcat/super/sub/update', methods=["POST"])
def new_sub_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria = request.form["super_categoria"]
        categoria = request.form["categoria"]
        query = "INSERT INTO tem_outra (super_categoria, categoria) VALUES (%s, %s)"
        data = (super_categoria, categoria)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# a)4) Remover sub-categorias

@app.route('/categorias/remo_subcat')
def del_sub_category_form():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM tem_outra;"
        cursor.execute(query)
        dbConn.commit()
        return render_template("remo_sub_categoria.html", cursor=cursor) 
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

@app.route('/categorias/remo_subcat/super/')
def del_sub_category_aux_form():
    try:
        return render_template("remo_sub_categoria_super.html", params=request.args) 
    except Exception as e:
        return render_template("erro.html", error_message=e) 
        

@app.route('/categorias/remo_subcat/super/update', methods=["POST"])
def del_sub_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria = request.form["super_categoria"]
        categoria = request.form["categoria"]
        query = "DELETE FROM tem_outra WHERE super_categoria=(%s) AND categoria=(%s); COMMIT;"
        data = (super_categoria, categoria)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

###########################

# b) Inserir e remover um retalhista, com todas suas as responsabilidades 
# de reposições de produtos garantindo que esta operacao seja atomica

@app.route('/retalhistas/')
def list_retailers():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query  = "SELECT * FROM retalhista;"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# b)1) Inserir um retalhista

@app.route('/retalhistas/novo_ret')
def new_retailer_form():
    try:
        return render_template("novo_retalhista.html")
    except Exception as e:
        return render_template("erro.html", error_message=e) 

@app.route('/retalhistas/novo_ret/update', methods=["POST"])
def new_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin    = request.form["tin"]
        name   = request.form["name"]
        query  = "INSERT INTO retalhista (tin, name) VALUES (%s, %s)"
        data   = (tin, name)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

# b)2) Remover um retalhista, com todas suas as responsabilidades 
# de reposições de produtos garantindo que esta operacao seja atomica

@app.route('/retalhistas/remo_ret')
def del_retailer_form():
    try:
        return render_template("remo_retalhista.html", params=request.args)
    except Exception as e:
        return render_template("erro.html", error_message=e) 

@app.route('/retalhistas/remo_ret/update', methods=["POST"])
def del_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin    = request.form["tin"]
        query  = "START TRANSACTION; DELETE FROM responsavel_por WHERE tin=%s; DELETE FROM retalhista WHERE tin=%s; COMMIT;"
        data   = (tin,tin)
        cursor.execute(query, data)
        dbConn.commit()
        return query
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

###########################

# c) Listar todos os eventos de reposicao de uma IVM, apresentando
# o numero de unidades repostas por categoria de produto

@app.route('/eventos/')
def list_events_form():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query  = "SELECT * FROM IVM;"
        cursor.execute(query)
        return render_template("list_eventos.html", cursor=cursor)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

@app.route('/eventos/list/')
def list_ivm_events_form():
    try:
        return render_template("list_ivm_eventos.html", params=request.args)
    except Exception as e:
        return render_template("erro.html", error_message=e) 

@app.route('/eventos/list/update', methods=["POST"])
def list_events():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        num_serie = request.form["num_serie"]
        fabricante = request.form["fabricante"]

        query = "SELECT cat, SUM(unidades) FROM evento_reposicao NATURAL JOIN produto WHERE num_serie=(%s) AND fabricante=(%s) GROUP BY cat;"
        data = (num_serie, fabricante)
        cursor.execute(query, data)
        return render_template("eventos.html", cursor=cursor)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

###########################

# d) Listar todas as sub-categorias de uma super-categoria, a todos
# os niveis de profundidade

@app.route('/categorias/list_subcat')
def list_subcat_form():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM super_categoria;"
        cursor.execute(query)
        return render_template("list_sub_categorias.html", cursor=cursor)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

@app.route('/categorias/list_subcat/list/')
def list_subcat_super_form():
    try:
        return render_template("list_sub_categorias_super.html", params=request.args)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
        
@app.route('/categorias/list_subcat/list/update', methods=["POST"])
def list_subcat():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria = request.form["super_categoria"]

        query = "START TRANSACTION; SELECT categoria FROM tem_outra WHERE super_categoria=(%s);"
        data  = (super_categoria,)
        cursor.execute(query, data)

        output = []
        to_expand = []

        for row in cursor:
            output.append(row)
            to_expand.append(row)

        while len(to_expand) > 0:
            row = to_expand[0]
            to_expand = to_expand[1:]

            query = "SELECT categoria FROM tem_outra WHERE super_categoria=(%s);"
            data  = (row[0],)
            cursor.execute(query, data)

            for _row in cursor:
                output.append(_row)
                to_expand.append(_row)
        
        query = "COMMIT;"
        cursor.execute(query)

        return render_template("sub_categorias.html", cursor=output)
    except Exception as e:
        return render_template("erro.html", error_message=e) 
    finally:
        cursor.close()
        dbConn.close()

###########################

CGIHandler().run(app)


