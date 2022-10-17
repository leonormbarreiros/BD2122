drop table evento_reposicao;
drop table responsavel_por;
drop table retalhista;
drop table planograma;
drop table prateleira;
drop table instalada_em;
drop table ponto_de_retalho;
drop table IVM;
drop table tem_categoria;
drop table produto;
drop table tem_outra;
drop table super_categoria;
drop table categoria_simples;
drop table categoria;

----------------------------------------
-- Table Creation
----------------------------------------

-- Named constraints are global to the database.
-- Therefore the following use the following naming rules:
--   1. pk_table for names of primary key constraints
--   2. fk_table_another for names of foreign key constraints

create table categoria (
  nome varchar(100) not null unique,
  constraint pk_categoria primary key(nome)
);

create table categoria_simples (
  nome varchar(100) not null unique,
  constraint pk_categoria_simples primary key(nome),
  constraint fk_categoria_simples foreign key(nome) references categoria(nome)
);

create table super_categoria (
  nome varchar(100) not null unique,
  constraint pk_super_categoria primary key(nome),
  constraint fk_super_categoria foreign key(nome) references categoria(nome)
);

create table tem_outra (
  super_categoria varchar(100) not null, 
  categoria varchar(100) not null unique,
  constraint pk_tem_outra primary key(categoria),
  constraint fk_tem_outra foreign key(categoria) references categoria(nome)
);

create table produto (
  ean char(13) not null unique,
  cat varchar(100) not null,
  descr varchar(100) not null,
  constraint pk_produto primary key(ean),
  constraint fk_produto foreign key(cat) references categoria(nome)
);

create table tem_categoria (
  ean char(13) not null,
  nome varchar(100) not null,
  constraint fk_tem_categoria primary key(ean, nome),
  constraint fk_tem_categoria_nome foreign key(nome) references categoria(nome),
  constraint fk_tem_categoria_ean foreign key(ean) references produto(ean)
);

create table IVM (
  num_serie int not null,
  fabricante varchar(100),
  constraint pk_IVM primary key(num_serie, fabricante)
);

create table ponto_de_retalho (
  nome varchar(100) not null unique,
  distrito varchar(100) not null,
  concelho varchar(100) not null,
  constraint pk_ponto_de_retalho primary key(nome)
);

create table instalada_em (
  num_serie int not null, 
  fabricante varchar(100) not null,
  localization varchar(100) not null,
  constraint pk_instalada_em primary key(num_serie, fabricante),
  constraint fk_instalada_em_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
  constraint fk_instalada_em_ponto_de_retalho foreign key(localization) references ponto_de_retalho(nome)
);

create table prateleira (
  nro int not null,
  num_serie int not null, 
  fabricante varchar(100) not null,
  altura int not null,
  nome varchar(100) not null,
  constraint pk_prateleira primary key(nro, num_serie, fabricante),
  constraint pk_prateleira_categoria foreign key(nome) references categoria(nome),
  constraint pk_prateleira_ivm foreign key(num_serie,fabricante) references IVM(num_serie,fabricante)
);

create table planograma (
  ean char(13) not null,
  nro int not null,
  num_serie int not null,
  fabricante varchar(100) not null,
  faces int not null,
  unidades int not null,
  loc varchar(100) not null,
  constraint pk_planograma primary key(ean, nro, num_serie, fabricante),
  constraint fk_planograma_produto foreign key(ean) references produto(ean),
  constraint fk_planograma_prateleira foreign key (nro, num_serie, fabricante) references prateleira(nro, num_serie, fabricante)
);

create table retalhista (
  tin varchar(100) not null unique,
  name varchar(100) not null unique,
  constraint pk_retalhista primary key(tin)
);

create table responsavel_por (
  nome_cat varchar(100) not null,
  tin varchar(100) not null,
  num_serie int not null,
  fabricante varchar(100) not null,
  constraint pk_responsavel_por primary key(num_serie, fabricante),
  constraint fk_responsavel_por_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
  constraint fk_responsavel_por_retalhista foreign key(tin) references retalhista(tin),
  constraint fk_responsavel_por_categoria foreign key(nome_cat) references categoria(nome)
);

create table evento_reposicao (
  ean char(13) not null,
  nro int not null,
  num_serie int not null,
  fabricante varchar(100) not null,
  instante timestamp not null,
  unidades int not null,
  tin varchar(100) not null,
  constraint pk_evento_reposicao primary key(ean, nro, num_serie, fabricante, instante),
  constraint fk_evento_reposicao_planograma foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante),
  constraint fk_evento_reposicao_retalhista foreign key(tin) references retalhista(tin)
);

----------------------------------------
-- Populate Relations 
----------------------------------------

insert into categoria values ('Vegetariano');
insert into categoria values ('Iogurte');
insert into categoria values ('Leite');
insert into categoria values ('Lacticinios');
insert into categoria values ('Vegan');
insert into categoria values ('Bio');
insert into categoria values ('Carne');

insert into categoria_simples values ('Iogurte');
insert into categoria_simples values ('Leite');
insert into categoria_simples values ('Vegan');
insert into categoria_simples values ('Bio');
insert into categoria_simples values ('Carne');

insert into super_categoria values ('Lacticinios');
insert into super_categoria values ('Vegetariano');
insert into super_categoria values ('Bio');

insert into tem_outra values ('Lacticinios','Iogurte');
insert into tem_outra values ('Lacticinios','Leite');
insert into tem_outra values ('Vegetariano','Vegan');
insert into tem_outra values ('Bio','Vegetariano');

insert into produto values ('1234567891011', 'Lacticinios', 'Mozzarella');
insert into produto values ('1234567891012', 'Vegetariano', 'Nuggets');
insert into produto values ('1234567891013', 'Vegan', 'Bolo de Bolacha');
insert into produto values ('1234567891014', 'Carne', 'Frango');
insert into produto values ('1234567891015', 'Leite', 'Leite de Chocolate');
insert into produto values ('1234567891016', 'Iogurte', 'Iogurte Grego');
insert into produto values ('1234567891017', 'Bio', 'Tomate Cherry');
insert into produto values ('1234567891018', 'Vegan', 'Pizza');
insert into produto values ('1234567891019', 'Carne', 'Picanha');

insert into tem_categoria values ('1234567891011','Lacticinios');
insert into tem_categoria values ('1234567891012','Vegetariano');
insert into tem_categoria values ('1234567891013','Vegan');
insert into tem_categoria values ('1234567891014','Carne');
insert into tem_categoria values ('1234567891015','Leite');
insert into tem_categoria values ('1234567891016','Iogurte');
insert into tem_categoria values ('1234567891017','Bio');
insert into tem_categoria values ('1234567891018','Vegan');
insert into tem_categoria values ('1234567891019','Carne');

insert into IVM values ('154','Fabricante1');

insert into ponto_de_retalho values ('Auchan - Almada','Setubal', 'Almada');

insert into instalada_em values ('154','Fabricante1','Auchan - Almada');

insert into prateleira values ('1', '154', 'Fabricante1', '14', 'Vegetariano');
insert into prateleira values ('2', '154', 'Fabricante1', '14', 'Bio');
insert into prateleira values ('3', '154', 'Fabricante1', '14', 'Vegan');
insert into prateleira values ('4', '154', 'Fabricante1', '12', 'Iogurte');
insert into prateleira values ('5', '154', 'Fabricante1', '12', 'Carne');
insert into prateleira values ('6', '154', 'Fabricante1', '12', 'Lacticinios');
insert into prateleira values ('7', '154', 'Fabricante1', '17', 'Vegetariano');
insert into prateleira values ('8', '154', 'Fabricante1', '17', 'Bio');
insert into prateleira values ('9', '154', 'Fabricante1', '17', 'Vegan');
insert into prateleira values ('10', '154', 'Fabricante1', '15', 'Iogurte');
insert into prateleira values ('11', '154', 'Fabricante1', '15', 'Carne');
insert into prateleira values ('12', '154', 'Fabricante1', '15', 'Lacticinios');

insert into planograma values ('1234567891011', '1', '154', 'Fabricante1', '3','5','Auchan - Almada');
insert into planograma values ('1234567891012', '2', '154', 'Fabricante1', '6','9','Auchan - Almada');
insert into planograma values ('1234567891013', '3', '154', 'Fabricante1', '12','6','Auchan - Almada');
insert into planograma values ('1234567891014', '4', '154', 'Fabricante1', '3','7','Auchan - Almada');
insert into planograma values ('1234567891015', '5', '154', 'Fabricante1', '5','10','Auchan - Almada');
insert into planograma values ('1234567891016', '6', '154', 'Fabricante1', '4','23','Auchan - Almada');
insert into planograma values ('1234567891017', '7', '154', 'Fabricante1', '4','2','Auchan - Almada');
insert into planograma values ('1234567891018', '8', '154', 'Fabricante1', '2','10','Auchan - Almada');
insert into planograma values ('1234567891019', '9', '154', 'Fabricante1', '5','15','Auchan - Almada');

insert into retalhista values ('222333', 'Josefina');
insert into retalhista values ('222444', 'Benjamim');

insert into responsavel_por values ('Lacticinios','222333', '154', 'Fabricante1');

insert into evento_reposicao values ('1234567891011', '1', '154', 'Fabricante1', '2001-05-09 15:00:00', '1', '222333');
insert into evento_reposicao values ('1234567891012', '2', '154', 'Fabricante1', '2001-06-10 18:45:00', '1', '222333');
insert into evento_reposicao values ('1234567891013', '3', '154', 'Fabricante1', '2001-06-23 09:00:05', '1', '222444');
insert into evento_reposicao values ('1234567891014', '4', '154', 'Fabricante1', '2013-05-23 12:20:00', '1', '222333');
insert into evento_reposicao values ('1234567891015', '5', '154', 'Fabricante1', '2020-06-23 15:00:00', '1', '222333');
insert into evento_reposicao values ('1234567891016', '6', '154', 'Fabricante1', '2021-12-07 08:23:02', '1', '222444');
insert into evento_reposicao values ('1234567891017', '7', '154', 'Fabricante1', '2001-05-09 15:00:00', '1', '222333');
insert into evento_reposicao values ('1234567891018', '8', '154', 'Fabricante1', '2001-06-10 18:45:00', '1', '222333');
insert into evento_reposicao values ('1234567891019', '9', '154', 'Fabricante1', '2001-06-23 09:00:05', '1', '222444');
