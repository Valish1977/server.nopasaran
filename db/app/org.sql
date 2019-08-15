-------------------------------------------------------------------------------------

create table app.org (
    id serial primary key,
    geo_id smallint references ref.geo,
    name varchar(250) not null,
    email varchar(100),
    url varchar(250),
    comment text,
    active boolean default true not null
);


-------------------------------------------------------------------------------------

create function auth.my_org_id()
returns integer
stable
language sql
as $$
    --select nullif( current_setting('request.jwt.claim.user_id', true) )::integer;
    select current_setting('request.jwt.claim.org_id', true)::integer;
$$;


-------------------------------------------------------------------------------------

create view api.org as
  select *
from app.org;

grant select on api.org to anon;

grant select on api.org to appuser;
grant select, update, insert on api.org to adm;