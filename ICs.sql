
DROP TRIGGER IF EXISTS not_contain_trigger ON tem_outra;
DROP TRIGGER IF EXISTS not_exceed_trigger ON evento_reposicao;
DROP TRIGGER IF EXISTS has_category_trigger ON evento_reposicao;

-- (RI-1) Uma Categoria nao pode estar contida em si propria
CREATE OR REPLACE FUNCTION not_contain() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.super_categoria = NEW.categoria THEN
        RAISE EXCEPTION 'Category % cannot contain itself', NEW.categoria;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER not_contain_trigger
BEFORE UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE not_contain();

-- (RI-2) O numero de unidades repostas num Evento de Reposicao nao 
-- pode exceder o numero de unidades especificado no Planograma
CREATE OR REPLACE FUNCTION not_exceed() RETURNS TRIGGER AS
$$
DECLARE max_unidades INTEGER;
BEGIN
    SELECT unidades
    INTO max_unidades
    FROM planograma
    WHERE ean = NEW.ean AND nro = NEW.nro AND num_serie = NEW.num_serie AND fabricante = NEW.fabricante;

    IF NEW.unidades > max_unidades THEN
        RAISE EXCEPTION 'Number of replaced units exceeds the maximum allowed by planogram: %', max_unidades;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER not_exceed_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE not_exceed();

-- (RI-3) Um Produto so pode ser reposto numa Prateleira que apresente
-- (pelo menos) uma das Categorias desse produto
CREATE OR REPLACE FUNCTION has_category() RETURNS TRIGGER AS
$$
DECLARE 
    categoria VARCHAR(100);
    categoria_prat VARCHAR(100);
    cursor_categorias CURSOR FOR SELECT nome FROM tem_categoria WHERE ean = NEW.ean;
BEGIN
    SELECT nome
    INTO categoria_prat
    FROM prateleira
    WHERE nro = NEW.nro AND num_serie = NEW.num_serie AND fabricante = NEW.fabricante;

    -- iterar sobre as categorias do produto 
    OPEN cursor_categorias;
    LOOP
        FETCH cursor_categorias INTO categoria;
        EXIT WHEN NOT FOUND;

        -- se a categoria for igual a da prateleira, OK :)
        IF categoria = categoria_prat THEN
            RETURN NEW;
        END IF;

    END LOOP;
    CLOSE cursor_categorias;

    -- chegando aqui, nao encontrou :(
    RAISE EXCEPTION 'The product must be replaced in a shelf which presents one of its categories';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER has_category_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE has_category();


