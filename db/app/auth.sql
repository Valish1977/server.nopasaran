
-------------------------------------------------------------------------------------

-- auth token secret
create function auth.get_jwt_at_secret()
	returns varchar(32) immutable as
		'select (':quoted_at_jwt_secret')::varchar' 
	language sql ;

-------------------------------------------------------------------------------------

-- refresh token secret
create function auth.get_jwt_rt_secret()
	returns varchar(32) immutable as
		'select (':quoted_rt_jwt_secret')::varchar' 
	language sql ;

-------------------------------------------------------------------------------------

-- store for refresh_token
create table auth.rt_store (
	token text primary key,
	user_id int references app.user,
	expired bigint
);

grant select, insert, delete on table auth.rt_store to anon;

-------------------------------------------------------------------------------------

-- returning result type for api.login and api.refresh
CREATE TYPE auth.auth_result AS (
  auth_token text,
  refresh_token text,
  prefs_changed text,
  ref_version json
);

-------------------------------------------------------------------------------------

-- check is user exist with login and pass (used in api.login)
create function auth.check_user(ulogin text, upass text) returns app.user as $$
  --select id,code, name, district_id, rdl, null,null,role_code,active, prefs from app.user
  --select id,name,null,null,role_code,active,'{}'::jsonb from app.user
  select * from app.user
   where login = ulogin
     and hash = pgcrypto.crypt(upass, hash)
$$ language sql;


-------------------------------------------------------------------------------------

-- make tokens and ref version (api.login and api.refresh)
create function auth.get_tokens(_user app.user) returns auth.auth_result as $$
declare
  _created bigint;
  _at text; -- auth token
  _rt text; -- refresh token
  _rv json; -- ref_version
  _result auth.auth_result;
begin

  select extract(epoch from now()) into _created;

  select pgjwt.sign(
      row_to_json(r), auth.get_jwt_at_secret()
    ) as token
    from (
      select _user.role_code as role, _user.id as user_id,  _user.org_id as org_id,  _created + 60*60 as exp -- set ttl for auth_token (1 hour) 
    ) r
    into _at;

  select pgjwt.sign(
      row_to_json(r), auth.get_jwt_rt_secret()
    ) as token
    from (
      select _user.role_code as role, _user.id as user_id,  _user.org_id as org_id, _created + 60*60*24*3 as exp -- set ttl for refresh_token (3 days) 
    ) r
    into _rt;

  insert into auth.rt_store ("token", user_id, expired) values(_rt, _user.id , _created + 60*60*24*3); -- set ttl for refresh_token in db

  select jsonb_agg(r.*) from ref.version r into _rv;

  --select _at, _rt, row_to_json(_user), _rv::json into _result;
  select _at, _rt, _user.prefs_changed::text, _rv::json into _result;

  return _result;
end;
$$ language plpgsql;




-------------------------------------------------------------------------------------



-- log
create table auth.log_access (
	id bigserial not null primary key,
  saved timestamp not null default now(),
	login varchar(20) NULL,
  headers text,
	udata jsonb
);

grant insert on table auth.log_access to anon;
grant usage, select on sequence auth.log_access_id_seq to anon;



-------------------------------------------------------------------------------------


-- login function
create function api.login(ulogin text, upass text, udata json) returns auth.auth_result as $$
declare
  _user app.user;
  _rh text;
begin
    --raise info 'udata %', udata;
  -- check email and password
  select * from auth.check_user(ulogin, upass) into _user;

  if _user is null or _user.active = false then
    raise invalid_password using message = 'invalid user or password';
  end if;

   select current_setting('request.header.X-Forwarded-For', true) into _rh;
   --raise log 'Forwarded: %', _rh;
  insert into auth.log_access (login, headers, udata) values(ulogin, _rh, udata::jsonb);
 
  return auth.get_tokens(_user);
end;
$$ language plpgsql;

grant execute on function api.login(text,text,json) to anon;


-------------------------------------------------------------------------------------

-- refresh function
create function api.refresh(refresh_token text) returns auth.auth_result as $$
declare
  _user app.user;
  _t record;
  _c int;
begin
    select * from pgjwt.verify(refresh_token, auth.get_jwt_rt_secret()) into _t;
  
  if _t.valid = false then
    raise invalid_password using message = 'invalid token';
  end if;

  --raise log '_t=%',_t;

  --select id,name,null,null,role_code,active,'{}'::jsonb 
  --select id,code, name, district_id, rdl, null,null,role_code,active, prefs
  select u.* 
    from auth.rt_store s join app.user u on s.user_id = u.id 
    where u.id=(_t.payload->>'user_id')::int and s.token = refresh_token into _user;

  --select (t.*)::app.user from (select _t.payload->>'user_id',_t.payload->>'user_name',null,null,_t.payload->>'role', true,'{}'::jsonb) t into _user;
  
  if _user is null or _user.active = false then
    raise invalid_password using message = 'invalid user';
  end if; 

  --del token
  delete from auth.rt_store where token = refresh_token;

  return auth.get_tokens(_user);
end;
$$ language plpgsql;

grant execute on function api.refresh(text) to anon;

-------------------------------------------------------------------------------------
