
create table app.event (
    id serial primary key,
    user_id int references app.user,
    org_id int references app.org,
    saved timestamp with time zone default now() not null,

    type_id smallint references ref.event_type,
	way_id smallint references ref.event_way,
	geo_id smallint references ref.geo,
	adress varchar(250),
	edate timestamptz,
    duration int,
	topic varchar(250),
	descr text,
	econtent jsonb,
	ematerials jsonb,
	tplparam jsonb,
    active boolean default false not null,
	approved boolean default false not null,

    del boolean default false not null,
    del_dt timestamp with time zone,
    del_reason character varying(250)
);

grant select on app.event to anon;
-------------------------------------------------------------------------------------

\ir event_reg.sql

-------------------------------------------------------------------------------------

create view api.event as 
    select *, (select count(id) from app.event_reg where event_id = app.event.id) as reg_count
    from app.event
    where auth.my_role() = 'adm' or org_id = auth.my_org_id()
    with local check option;

grant select, update, insert on api.event to appuser;


create view api.event_site as 
    select *
    from app.event
    where approved = true and active = true;

grant select on api.event_site to anon;
