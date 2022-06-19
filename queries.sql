-- Qual o nome do retalhista(ou retalhistas) repsonsáveis pela reposição do
--  maior número de categorias? TODO verificar se aparece vários


select count(nome_cat), r.nome from retalhista r
join responsavel_por rp on r.tin = rp.tin
join evento_reposicao er on r.tin = er.tin
group by r.nome
having count(nome_cat) >= ALL (
    select count(nome_cat) from retalhista r
    join responsavel_por rp on r.tin = rp.tin
    --join evento_reposicao er on r.tin = er.tin
    group by r.nome
);


-- Qual o nome do ou dos retalhistas que são responsáveis por todas as categorias simples?
-- escolher os retalhistas responsáveis por pelo menos 1 cat simples

select *
from retalhista r
join responsavel_por rp on r.tin = rp.tin
where rp.nome_cat not in (
    select super_categoria
    from tem_outra
    );


-- Quais os produtos (ean) que nunca foram repostos?

select p.ean
from evento_reposicao er
right outer join produto p on er.ean = p.ean
where er.ean is null;


-- Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista?
select er.ean
from evento_reposicao er
group by er.ean
having max(er.tin) = min(er.ean);
