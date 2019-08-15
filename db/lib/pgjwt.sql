create schema pgjwt;

create or replace function pgjwt.url_encode(data bytea) RETURNS text LANGUAGE sql as $$
    select translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;

create or replace function pgjwt.url_decode(data text) RETURNS bytea LANGUAGE sql as $$
WITH t as (select translate(data, '-_', '+/') as trans),
     rem as (select length(t.trans) % 4 as remainder from t) -- compute padding size
    select decode(
        t.trans ||
        case when rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           else '' end,
    'base64') from t, rem;
$$;

create or replace function pgjwt.algorithm_sign(signables text, secret text, algorithm text)
RETURNS text LANGUAGE sql as $$
WITH
  alg as (
    select case
      when algorithm = 'HS256' THEN 'sha256'
      when algorithm = 'HS384' THEN 'sha384'
      when algorithm = 'HS512' THEN 'sha512'
      else '' end as id)  -- hmac throws error
select pgjwt.url_encode(pgcrypto.hmac(signables, secret, alg.id)) from alg;
$$;

create or replace function pgjwt.sign(payload json, secret text, algorithm text default 'HS256')
RETURNS text LANGUAGE sql as $$
WITH
  header as (
    select pgjwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) as data
    ),
  payload as (
    select pgjwt.url_encode(convert_to(payload::text, 'utf8')) as data
    ),
  signables as (
    select header.data || '.' || payload.data as data from header, payload
    )
select
    signables.data || '.' ||
    pgjwt.algorithm_sign(signables.data, secret, algorithm) from signables;
$$;

create or replace function pgjwt.verify(token text, secret text, algorithm text default 'HS256')
RETURNS table(header json, payload json, valid boolean) LANGUAGE sql as $$
  select
    convert_from(pgjwt.url_decode(r[1]), 'utf8')::json as header,
    convert_from(pgjwt.url_decode(r[2]), 'utf8')::json as payload,
    r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) as valid
  from regexp_split_to_array(token, '\.') r;
$$;