
\echo # ISRC DB

-- some setting to make the output less verbose
--\set QUIET on
\set ON_ERROR_STOP on
--set client_min_messages to warning;

-- load some variables from the env
\setenv base_dir :DIR
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set authenticator `echo $DB_AUTHENTICATOR`
\set authenticator_pass `echo $DB_AUTHENTICATOR_PWD`
\set jwt_at_secret `echo $JWT_AT_SECRET`
\set quoted_at_jwt_secret '\'' :jwt_at_secret '\''
\set jwt_rt_secret `echo $JWT_RT_SECRET`
\set quoted_rt_jwt_secret '\'' :jwt_rt_secret '\''



\echo # create roles
create role :"authenticator" with login password :'authenticator_pass';

create role anon;
grant anon to :"authenticator";

create role appuser;
grant appuser to :"authenticator";


\echo # loading database
begin;

create schema auth;
create schema ref;
create schema app;
create schema api;

drop schema public;

create schema pgcrypto;
create extension pgcrypto with schema pgcrypto;

\ir lib/pgjwt.sql

grant usage on schema app, ref, auth, api, pgcrypto, pgjwt to anon;
grant usage on schema app, ref, auth, api, pgcrypto, pgjwt to appuser;
grant select on table pg_authid to anon;
grant select on table pg_authid to appuser;

create role adm nologin;
grant appuser to adm;
grant adm to authenticator;

create role cl nologin;
grant appuser to cl;
grant cl to authenticator;



\ir ref/ref.sql
\ir app/app.sql



-- current_setting(request.jwt.claim., true);
-- current_setting('request.jwt.claim.email', true)

commit;
\echo # ==========================================