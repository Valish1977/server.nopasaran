
-- notice
create table app.notice (
    id serial primary key,
    user_id int references app.user,
    saved timestamp with time zone default now() not null,
    topic varchar(50),
    descr text,
    from_date date,
    until_date date,
    active boolean not null default false
);

-------------------------------------------------------------------------------------
-- notice
create view api.notice as
select
  n.id,
  n.user_id,
  n.saved,
  n.topic,
  n.descr,
  n.from_date,
  n.until_date,
  n.active,
  (
    case when n.active = true then
      case when n.from_date is null
        and n.until_date is null then
        true
      when n.from_date is null
        and current_date < n.until_date then
        true
      when current_date >= n.from_date
        and n.until_date is null then
        true
      when current_date between n.from_date
        and n.until_date then
        true
      else
        false
      end
    else
      false
    end) as actual
from
  app.notice n;

grant select on api.notice to appuser;

grant select, update, insert, delete on api.notice to adm;


