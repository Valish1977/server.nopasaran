
-- ref 

create table ref.geo (
	id smallint primary key,
    pid smallint,
    name varchar(50) not null,
    tr JSONB,
    geotype smallint
);

create view api.ref_geo as 
    select id, pid, name, tr, geotype from ref.geo;
grant select on api.ref_geo to appuser;

grant select on api.ref_geo to anon;

insert into ref.version ("name", "version") values('ref_geo', '2019.03.15.1');

insert into ref.geo (id, pid, name, tr, geotype) values 
(2,1,'Уфа','{"ru": "Уфа", "eng": "Ufa"}',2)
,(1,0,'Россия','{"ru": "Россия", "eng": "Russia"}',1)
;
