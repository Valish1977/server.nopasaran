
-- ref 

create table ref.event_type (
	id smallint primary key,
    name varchar(50) not null,
    tr JSONB
);

create view api.ref_event_type as 
    select id, name from ref.event_type;
grant select on api.ref_event_type to appuser;

grant select on api.ref_event_type to anon;

insert into ref.version ("name", "version") values('ref_event_type', '2019.03.15.1');

insert into ref.event_type (id, name, tr) values 
(1,'Семинар','{"ru": "Семинар", "eng": "Seminar"}')
,(2,'Лекция','{"ru": "Лекция", "eng": "Lection"}')
,(3,'Открытый урок','{"ru": "Открытый урок", "eng": "Open lesson"}')
;
