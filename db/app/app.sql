
-------------------------------------------------------------------------------------

--- Init app data

\ir role.sql

\ir org.sql

\ir user.sql

\ir auth.sql


-------------------------------------------------------------------------------------

--- App data

\ir notice.sql

\ir event/event.sql


--\ir sd.sql

\ir test_data.sql


-- after all tables
--grant select on all tables in schema app to appuser;
grant usage, select on all sequences in schema app to appuser;
