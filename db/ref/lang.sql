
-- ref languages

create table ref.lang (
	code varchar(3) primary key,
    name varchar(50) not null
);

create view api.ref_lang as 
    select code, name from ref.lang;
grant select on api.ref_lang to appuser;

grant select on api.ref_lang to anon;

insert into ref.version ("name", "version") values('ref_lang', '2019.03.15.1');

insert into ref.lang (code, name) values 
('ru', 'Русский')
;
