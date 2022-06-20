drop view Vendas;

-- ean e cat: correspondem às chaves primárias das relações produto e categoria, respectivamente
-- ano, trimestre, mes, dia_mes, dia_semana: atributos derivados do atributo instante
-- distrito e concelho: correspondem aos atributos com o mesmo nome de ponto_de_retalho
-- unidades: corresponde ao atributo com o mesmo nome da relação evento_reposicao
create view Vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades)
as
    select
        er.ean,
        rp.nome_cat,
        extract(year from er.instante) as ano,
        extract(quarter from er.instante) as trimestre,
        extract(month from er.instante) as mes,
        extract(day from er.instante) as dia_mes,
        extract(dow from er.instante) as dia_semana,
        pdr.distrito,
        pdr.concelho,
        er.unidades
    from evento_reposicao er
    join responsavel_por rp on er.tin = rp.tin
    join ivm i on rp.num_serie = i.num_serie
    join instalada_em ie on i.num_serie = ie.num_serie
    join ponto_de_retalho pdr on ie.local_ = pdr.nome
;
