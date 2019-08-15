
create table app.event_reg (
    id serial primary key,
    saved timestamp with time zone default now() not null,

    org_id int references app.org,
    event_id int references app.event,
	  name varchar(150),
	  email varchar(150),
	  approved boolean default false not null,
     unique (event_id, email)
);

grant insert on app.event_reg to anon;
grant usage, select on sequence app.event_reg_id_seq to anon;
-------------------------------------------------------------------------------------

create view api.event_reg as 
    select *
    from app.event_reg
    where auth.my_role() = 'adm' or org_id = auth.my_org_id()
    with local check option;

grant select, update on api.event_reg to appuser;

-------------------------------------------------------------------------------------

create function api.event_reg_form (f app.event_reg)
  returns boolean
  as $$
declare
_org_id int;
--  _id int;
begin

select org_id from app.event where id = f.event_id into _org_id;
if _org_id is null then 
  raise exception 'incorrect event' USING ERRCODE = 'P0001';
  --return; 
end if;

insert into app.event_reg (org_id, event_id, name, email) values(_org_id, f.event_id, f.name, f.email) ; --into _id;

return true;

end;
$$
language plpgsql;

grant execute on function api.event_reg_form(app.event_reg) to anon;
