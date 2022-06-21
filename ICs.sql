-- IRs USING STORED PROCEDURE TRIGGERS


-- RI-1
CREATE OR REPLACE FUNCTION chk_cycle_category()
RETURNS TRIGGER AS
$$
DECLARE ctg varchar(80);
BEGIN
    ctg := NEW.super_categoria;
    LOOP
        IF(SELECT COUNT(*)
        FROM tem_outra
        WHERE categoria=ctg) = 0 THEN
            RETURN NEW;
        ELSE
            SELECT super_categoria into ctg
            FROM tem_outra
            WHERE categoria=ctg;
            IF ctg=NEW.categoria THEN
                RAISE EXCEPTION 'A category can NOT be a subcategory of itself';
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_category_trigger
BEFORE UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE chk_cycle_category();


-- RI-4
CREATE OR REPLACE FUNCTION chk_replenishment_units()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.unidades > (
        SELECT unidades
        FROM planograma as P
        WHERE P.ean = NEW.ean
        AND P.nro = NEW.nro
        AND P.num_serie = NEW.num_serie
        AND P.fabricante = NEW.fabricante
    ) THEN
        RAISE EXCEPTION 'Unities replenished exceed the planogram maximum unities';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_replenishment_units_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE chk_replenishment_units();


-- RI-5
CREATE OR REPLACE FUNCTION chk_planogram_categories()
RETURNS TRIGGER AS
$$
DECLARE prateleira_ctg varchar(80);
DECLARE producto_ctg varchar(80);
BEGIN
    SELECT nome into prateleira_ctg
    FROM prateleira as P
    WHERE NEW.nro = P.nro
    AND NEW.num_serie = P.num_serie
    AND NEW.fabricante = P.fabricante;
    IF prateleira_ctg IN (
    SELECT nome 
    FROM tem_categoria as T
    WHERE NEW.ean = T.ean
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'A product can only be put in a shelf that
         supports the same category the product belongs to';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_planogram_categories_trigger
BEFORE UPDATE OR INSERT ON planograma
FOR EACH ROW EXECUTE PROCEDURE chk_planogram_categories();