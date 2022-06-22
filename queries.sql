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


















-- TODO apagar depois
start transaction;
drop table if exists t;
with recursive remove_category(super_categoria, categoria) as (
    select super_categoria, categoria from tem_outra t_o where t_o.super_categoria = 'Padaria' or t_o.categoria = 'Padaria'
    union all
    select t_o.super_categoria, t_o.categoria from tem_outra t_o
        inner join remove_category rsc on rsc.categoria = t_o.super_categoria
)
select categoria into t from remove_category;
insert into t values('Padaria');

delete from responsavel_por where nome_cat in (select * from t);
delete from tem_categoria where nome in (select * from t);
delete from tem_outra where super_categoria in (select categoria from t) or
                            categoria in (select categoria from t);
delete from super_categoria where nome in (select categoria from t);
delete from categoria_simples where nome in (select categoria from t);
delete from evento_reposicao er where exists (
    select 1 from produto prod where prod.ean = er.ean and exists (
        select 1 from categoria cat where cat.nome = 'Padaria'
    )
);
delete from planograma plan where exists (
    select 1 from produto prod where plan.ean = prod.ean and exists (
        select 1 from categoria cat where cat.nome = 'Padaria'
    )
);
delete from produto where cat in (select * from t);
delete from prateleira where nome in (select * from t);
delete from categoria where nome in (select * from t);
commit;










delete from tem_outra where super_categoria in (select cat from t) or
                            categoria in (select cat from t);
delete from super_categoria where nome in (select cat from t);
delete from categoria_simples where nome in (select cat from t);
delete from categoria where nome in (select  cat from t);
commit;








---delete from produto where cat in (select categoria from t) or
---                            cat in (select super_categoria from t);
--delete from planograma
--delete from prateleira where nome in (select categoria from t) or
 --                           nome in (select super_categoria from t);
--
--delete from categoria where nome in (select categoria from t);
--delete from categoria_simples where nome in (select categoria from t);

drop table t;
commit;