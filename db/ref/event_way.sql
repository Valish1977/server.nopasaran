
-- ref 

create table ref.event_way (
	id smallint primary key,
    name varchar(50) not null,
    tr jsonb,
    tplparam jsonb
);

create view api.ref_event_way as 
    select id, name, tr, tplparam from ref.event_way;
grant select on api.ref_event_way to appuser;

grant select on api.ref_event_way to anon;

insert into ref.version ("name", "version") values('ref_event_way', '2019.03.15.1');

insert into ref.event_way (id, name, tr, tplparam) values 
(1,'Философия','{"ru": "Философия", "eng": "Philosofy"}','{"event": {"topBackground": "theme1.jpg"}}')
,(2,'Наука','{"ru": "Наука", "eng": "Science"}','{"event": {"topBackground": "theme2.jpg"}}')
,(3,'Политэкономия','{"ru": "Политэкономия", "eng": "Political economy"}','{"event": {"topBackground": "theme3.png"}}')
;
