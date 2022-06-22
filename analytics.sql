-- Consultas OLAP


-- 1) Artigos vendidos num dado periodo, por dia da semana, por concelho e no total

SELECT dia_semana, concelho, SUM(unidades) as unidades
FROM vendas as V
WHERE make_date(V.ano, V.mes, V.dia_mes)
     BETWEEN '2022-11-20 00:00:00' AND '2022-12-19 23:59:59'
GROUP BY
    GROUPING SETS ((dia_semana), (concelho), ());


-- 2) Artigos vendidos num dado distrito, por concelho, categoria, dia da semana e no total

SELECT concelho, cat as categoria, dia_semana, SUM(unidades) as unidades
FROM vendas
WHERE distrito = 'Lisboa'
GROUP BY
    GROUPING SETS ((concelho), (categoria), (dia_semana), ());
