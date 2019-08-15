
-- app users
create table app.user (
    id serial primary key,
    org_id int references app.org,
    name varchar(250) not null,
    email varchar(100),
    login varchar(100) not null unique,
    hash varchar(100),
    role_code varchar(5) references auth.role,
    active boolean default true not null,
    prefs jsonb,
    prefs_changed timestamp with time zone default now() not null
);

grant select on table app.user to anon;
grant select, update on table app.user to appuser;

-------------------------------------------------------------------------------------
-- encrypt trigger for app.user.hash 
create function auth.encrypt_pass() returns trigger as $$
begin
  if (new.hash is not null and new.hash != old.hash) or (new.hash is not null and old.hash is null) then
  	new.hash = pgcrypto.crypt(new.hash, pgcrypto.gen_salt('bf'));
  end if;
  return new;
end
$$ language plpgsql;

create trigger encrypt_pass
  before insert or update on app.user
  for each row
  execute procedure auth.encrypt_pass();

-------------------------------------------------------------------------------------


create function auth.my_user_id()
returns integer
stable
language sql
as $$
    --select nullif( current_setting('request.jwt.claim.user_id', true) )::integer;
    select current_setting('request.jwt.claim.user_id', true)::integer;
$$;


-------------------------------------------------------------------------------------

-- user
create view api.user as
select
  id,
  org_id,
  name,
  email,
  login,
  hash,
  role_code,
  active,
  prefs,
  prefs_changed
from
  app.user
where auth.my_role() = 'adm' or org_id = auth.my_org_id()
with local check option;

grant select on api.user to appuser;
grant select, update, insert on api.user to adm;



-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------

-- update user preferens 
create function api.update_prefs (p json)
  returns timestamp with time zone
  as $$
declare
  _now timestamp with time zone;
  _user_id int;
  _user_role varchar(5);
begin
  select current_setting('request.jwt.claim.user_id', true) into _user_id;
  select current_setting('request.jwt.claim.role', true) into _user_role;

  --raise log 'value %', sd.opi;
  select now() into _now;

  update app.user set prefs = p::jsonb, prefs_changed = _now where app.user.id = _user_id;
  
  return _now;

end;
$$
language plpgsql;

grant execute on function api.update_prefs(json) to appuser;




