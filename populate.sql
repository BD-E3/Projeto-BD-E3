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
    descr varchar(80),
    constraint pk_produto primary key(ean),
    constraint fk_produto_categoria foreign key(cat) references categoria(nome)
);

create table tem_categoria(
    ean numeric(13, 0) not null,
    nome varchar(80) not null,
    constraint fk_tem_categoria_produto foreign key(ean) references produto(ean),
    constraint fk_tem_categoria_categoria foreign key(nome) references categoria(nome)
);

create table IVM(
    num_serie int not null,
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
    num_serie int not null,
    fabricante varchar(80) not null,
    local_ varchar(80) not null,
    constraint pk_instalada_em primary key(num_serie, fabricante),
    constraint fk_instalada_em_IVM foreign key (num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_instalada_em_ponto_de_retalho foreign key(local_) references ponto_de_retalho(nome)
);

create table prateleira(
    nro smallint not null,
    num_serie int not null,
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
    num_serie int not null,
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
    constraint unq_retalhista_nome unique(nome)
);

create table responsavel_por(
    nome_cat varchar(80) not null,
    tin numeric(9, 0) not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    constraint pk_responsavel_por primary key(num_serie, fabricante),
    constraint fk_responsavel_por_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_responsavel_por_retalhista foreign key(tin) references retalhista(tin),
    constraint fk_responsavel_por_categoria foreign key(nome_cat) references categoria(nome)
);

create table evento_reposicao(
    ean numeric(13, 0) not null,
    nro smallint not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    instante varchar(10) not null,
    unidades int not null,
    tin numeric(9, 0) not null,
    constraint pk_evento_reposicao primary key(ean, nro, num_serie, fabricante, instante),
    constraint fk_evento_reposicao_planograma foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante),
    constraint fk_evento_reposicao_retalhista foreign key(tin) references retalhista(tin)
);