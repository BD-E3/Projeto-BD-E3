-- Reset previously existing relations
drop table categoria cascade;
drop table categoria_simples cascade;
drop table super_categoria cascade;
drop table tem_outra cascade;
drop table produto cascade;
drop table tem_categoria cascade;
drop table IVM cascade;
drop table ponto_de_retalho cascade;
drop table instalada_em cascade;
drop table prateleira cascade;
drop table planograma cascade;
drop table retalhista cascade;
drop table responsavel_por cascade;
drop table evento_reposicao cascade;

-- Create tables
create table categoria(
    nome varchar(80) not null,
    constraint pk_categoria primary key(nome)
);

create table categoria_simples(
    nome varchar(80) not null,
    constraint pk_categoria_simples primary key(nome),
    constraint fk_categoria_simples_categoria foreign key(nome) references categoria(nome)
);

create table super_categoria(
    nome varchar(80) not null,
    constraint pk_super_categoria primary key(nome),
    constraint fk_super_categoria_categoria foreign key(nome) references categoria(nome)
);

create table tem_outra(
    super_categoria varchar(80) not null,
    categoria varchar(80) not null,
    constraint pk_tem_outra primary key(categoria),
    constraint fk_tem_outra_super_categoria foreign key(super_categoria) references super_categoria(nome),
    constraint fk_tem_outra_categoria foreign key(categoria) references categoria(nome),
    constraint chk_tem_outra_rire5 check(super_categoria != categoria)
    -- RI-RE5
);


create table produto(
    ean numeric(13, 0) not null,
    cat varchar(80) not null,
    -- Nao e erro do enunciado, o produto e so bueda XPTO!
    descr varchar(80),
    constraint pk_produto primary key(ean),
    constraint fk_produto_categoria foreign key(cat) references categoria(nome)
);

create table tem_categoria(
    ean numeric(13, 0) not null,
    nome varchar(80) not null,
    constraint pk_tem_categoria primary key(ean, nome),
    constraint fk_tem_categoria_produto foreign key(ean) references produto(ean),
    constraint fk_tem_categoria_categoria foreign key(nome) references categoria(nome)
);

create table IVM(
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    constraint pk_ivm primary key(num_serie, fabricante)
);

create table ponto_de_retalho(
    nome varchar(80) not null,
    distrito varchar(80) not null,
    concelho varchar(80) not null,
    constraint pk_ponto_de_retalho primary key(nome)
);

create table instalada_em(
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    local_ varchar(80) not null,
    constraint pk_instalada_em primary key(num_serie, fabricante),
    constraint fk_instalada_em_IVM foreign key (num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_instalada_em_ponto_de_retalho foreign key(local_) references ponto_de_retalho(nome)
);

create table prateleira(
    nro smallint not null,
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    altura smallint not null,
    nome varchar(80) not null,
    constraint pk_prateleira primary key(nro, num_serie, fabricante),
    constraint fk_prateleira_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_prateleira_categoria foreign key(nome) references categoria(nome)
);

create table planograma(
    ean numeric(13, 0) not null,
    nro smallint not null,
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    faces smallint not null,
    unidades int not null,
    loc varchar(10) not null,
    constraint pk_planograma primary key(ean, nro, num_serie, fabricante),
    constraint fk_planograma_produto foreign key(ean) references produto(ean),
    constraint fk_planograma_prateleira foreign key(nro, num_serie, fabricante) references prateleira(nro, num_serie, fabricante)
);

create table retalhista(
    tin numeric(9, 0) not null,
    nome varchar(80) not null,
    constraint pk_retalhista primary key(tin),
    constraint unq_retalhista_nome unique(nome) -- RI-RE7
);

create table responsavel_por(
    nome_cat varchar(80) not null,
    tin numeric(9, 0) not null,
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    constraint pk_responsavel_por primary key(num_serie, fabricante),
    constraint fk_responsavel_por_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_responsavel_por_retalhista foreign key(tin) references retalhista(tin),
    constraint fk_responsavel_por_categoria foreign key(nome_cat) references categoria(nome)
);

create table evento_reposicao(
    ean numeric(13, 0) not null,
    nro smallint not null,
    num_serie varchar(25) not null,
    fabricante varchar(80) not null,
    instante timestamp not null,
    unidades int not null,
    tin numeric(9, 0) not null,
    constraint pk_evento_reposicao primary key(ean, nro, num_serie, fabricante, instante),
    constraint fk_evento_reposicao_planograma foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante),
    constraint fk_evento_reposicao_retalhista foreign key(tin) references retalhista(tin)
);

-- Populate with test data
insert into categoria
    (nome)
values
    ('Padaria'),
    ('Pao'),
    ('Integral'),
    ('Sem gluten'),
    ('Congelado'),
    ('Marisco'),
    ('Gelado'),

    ('Peixe'),
    ('Batata'),
    ('Fruta'),

    ('Vegetal'),
    ('Cenoura'),
    ('Banana'),
    ('Ananas'),
    ('Bolachas'),
    ('Cereais'),

    ('Carne'),
    ('Porco'),
    ('Bifana'),
    ('Chocolate'),
    ('Agua'),
    ('Sumos'),
    ('Compal');

insert into categoria_simples
    (nome)
values
    ('Integral'),
    ('Sem gluten'),
    ('Marisco'),
    ('Gelado'),
    ('Peixe'),
    ('Batata'),
    ('Cenoura'),
    ('Banana'),
    ('Ananas'),
    ('Bolachas'),
    ('Cereais'),
    ('Bifana'),
    ('Chocolate'),
    ('Agua'),
    ('Compal');

insert into super_categoria
    (nome)
values
    ('Padaria'),
    ('Pao'),
    ('Congelado'),
    ('Fruta'),
    ('Vegetal'),
    ('Carne'),
    ('Porco'),
    ('Sumos');

insert into tem_outra
    (super_categoria, categoria)
values
    ('Padaria', 'Pao'),
    ('Pao', 'Integral'),
    ('Pao', 'Sem gluten'),
    ('Congelado', 'Marisco'),
    ('Congelado', 'Gelado'),
    ('Carne', 'Porco'),
    ('Porco', 'Bifana'),
    ('Fruta', 'Banana'),
    ('Fruta', 'Ananas'),
    ('Vegetal', 'Cenoura'),
    ('Vegetal', 'Batata'),
    ('Sumos', 'Compal');

insert into produto
    (ean, cat, descr) -- cat e a seccao onde sao vendidas - toume a cagar
values
    (2115721492019, 'Padaria', 'Pao de Mafra'),
    (8271348905123, 'Padaria', 'Pao de milho'),
    (0649152305112, 'Padaria', 'Baguette'),
    (3251277832424, 'Padaria', 'Pao sem gluten fatiado'),
    (0129401004126, 'Padaria', 'Pao integral fatiado');

insert into tem_categoria
    (ean, nome)
values
    (2115721492019, 'Pao'),
    (8271348905123, 'Pao'),
    (0649152305112, 'Pao'),
    (3251277832424, 'Sem gluten'),
    (0129401004126, 'Integral');

insert into IVM
    (num_serie, fabricante)
values
    ('21H98798H', 'Tecnico IVMs'),
    ('G19H28UH9', 'Tecnico IVMs'),
    ('ADMVCNAS8', 'Tecnico IVMs'),
    ('A890SHGH0SAHHD', 'IVMs da China'),
    ('XCVBNSBCICAS8A', 'IVMs da China'),
    ('BNS35HRBNFBF18', 'IVMs da China');

insert into ponto_de_retalho
    (nome, distrito, concelho)
values
    ('Social', 'Lisboa', 'Lisboa'),
    ('Valenciana', 'Lisboa', 'Lisboa'),
    ('Pingo Doce', 'Setubal', 'Alcacer do Sal');

insert into instalada_em
    (num_serie, fabricante, local_)
values
    ('21H98798H', 'Tecnico IVMs', 'Social'),
    ('G19H28UH9', 'Tecnico IVMs', 'Social'),
    ('ADMVCNAS8', 'Tecnico IVMs','Valenciana'),
    ('A890SHGH0SAHHD', 'IVMs da China', 'Valenciana'),
    ('XCVBNSBCICAS8A', 'IVMs da China', 'Pingo Doce'),
    ('BNS35HRBNFBF18', 'IVMs da China', 'Pingo Doce');

insert into prateleira
    (nro, num_serie, fabricante, altura, nome)
values
    (10, '21H98798H', 'Tecnico IVMs', 15, 'Marisco'),
    (12, '21H98798H', 'Tecnico IVMs', 10, 'Sem gluten'),
    (14, '21H98798H', 'Tecnico IVMs', 10, 'Integral'),
    (14, 'G19H28UH9', 'Tecnico IVMs', 15, 'Congelado'),
    (20, 'ADMVCNAS8', 'Tecnico IVMs', 10, 'Gelado'),
    (10, 'ADMVCNAS8', 'Tecnico IVMs', 14, 'Pao'),
    (8, 'A890SHGH0SAHHD', 'IVMs da China', 20, 'Pao'),
    (16, 'A890SHGH0SAHHD', 'IVMs da China', 25, 'Gelado'),
    (12, 'A890SHGH0SAHHD', 'IVMs da China', 15, 'Pao'),
    (16, 'XCVBNSBCICAS8A', 'IVMs da China', 14, 'Pao'),
    (10, 'BNS35HRBNFBF18', 'IVMs da China', 14, 'Padaria'),
    (4, 'BNS35HRBNFBF18', 'IVMs da China', 10, 'Integral');

insert into planograma
    (ean, nro, num_serie, fabricante, faces, unidades, loc)
values
    (2115721492019, 10, '21H98798H', 'Tecnico IVMs', 5, 10, 'idk'),
    (2115721492019, 12, '21H98798H', 'Tecnico IVMs', 4, 8, 'idk'),
    (8271348905123, 12, '21H98798H', 'Tecnico IVMs', 4, 4, 'idk'),
    (8271348905123, 14, 'G19H28UH9', 'Tecnico IVMs', 2, 6, 'idk'),
    (8271348905123, 20, 'ADMVCNAS8', 'Tecnico IVMs', 3, 9, 'idk'),
    (0649152305112, 10, 'ADMVCNAS8', 'Tecnico IVMs', 2, 6, 'idk'),
    (3251277832424, 16, 'A890SHGH0SAHHD', 'IVMs da China', 4, 4, 'idk'),
    (3251277832424, 12, 'A890SHGH0SAHHD', 'IVMs da China', 4, 8, 'idk'),
    (3251277832424, 16, 'XCVBNSBCICAS8A', 'IVMs da China', 1, 2, 'idk'),
    (0129401004126, 10, 'BNS35HRBNFBF18', 'IVMs da China', 5, 5, 'idk'),
    (0129401004126, 4, 'BNS35HRBNFBF18', 'IVMs da China', 1, 1, 'idk');

insert into retalhista
    (tin, nome)
values
    (120945109, 'Joao Pecados'),
    (228381278, 'Maria Joao');

insert into responsavel_por
    (nome_cat, tin, num_serie, fabricante)
values
    ('Padaria', 120945109, 'BNS35HRBNFBF18', 'IVMs da China'),
    ('Pao', 120945109, 'ADMVCNAS8', 'Tecnico IVMs'),
    ('Pao', 120945109, 'A890SHGH0SAHHD', 'IVMs da China'),
    ('Pao', 120945109, 'XCVBNSBCICAS8A', 'IVMs da China'),
    --('Integral', 120945109, '21H98798H', 'Tecnico IVMs'),
    --('Integral', 120945109, 'BNS35HRBNFBF18', 'IVMs da China'),
    ('Sem gluten', 228381278, '21H98798H', 'Tecnico IVMs'),
    ('Congelado', 120945109, 'G19H28UH9', 'Tecnico IVMs');
    --('Congelado', 120945109, 'ADMVCNAS8', 'Tecnico IVMs'),
    --('Marisco', 228381278, '21H98798H', 'Tecnico IVMs'),
    --('Gelado', 228381278, 'A890SHGH0SAHHD', 'IVMs da China');

insert into evento_reposicao
    (ean, nro, num_serie, fabricante, instante, unidades, tin)
values
    (2115721492019, 10, '21H98798H', 'Tecnico IVMs', '2022-12-17 12:23:41', 4, 120945109),
    (8271348905123, 14, 'G19H28UH9', 'Tecnico IVMs', '2022-11-03 09:24:00', 5, 120945109),
    (0649152305112, 10, 'ADMVCNAS8', 'Tecnico IVMs', '2022-12-22 20:13:25', 4, 228381278),
    (3251277832424, 12, 'A890SHGH0SAHHD', 'IVMs da China', '2022-11-23 19:55:01', 3, 228381278);