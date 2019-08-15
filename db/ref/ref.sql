create table ref.version (
    name varchar(30) primary key,
    version varchar(15) not null,
    local_update bool not null default true
);

grant select on table ref.version to anon;
grant select on table ref.version to appuser;

create view api.ref_version as 
    select name, version, local_update from ref.version;

grant select on api.ref_version to anon;     

\ir lang.sql
\ir geo.sql
\ir event_way.sql
\ir event_type.sql

