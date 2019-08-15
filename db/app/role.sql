

-- app user's roles
create table auth.role (
    code varchar(5) primary key,
    name varchar(30) not null
);

-------------------------------------------------------------------------------------


create function auth.my_role()
returns varchar
stable
language sql
as $$
    select current_setting('request.jwt.claim.role', true)::varchar;
$$;


-------------------------------------------------------------------------------------

create view api.ref_role as 
    select code, name 
    from auth.role;
   -- where auth.my_role() = 'adm' or code = auth.my_role()
   -- with local check option;

grant select on api.ref_role to appuser;
grant select on api.ref_role to anon;

insert into ref.version ("name", "version",local_update) values('ref_role', '2019.03.15.1', true);

-------------------------------------------------------------------------------------

insert into auth.role(code,"name") values 
('adm','Администратор')
,('cl','Клуб')
;

