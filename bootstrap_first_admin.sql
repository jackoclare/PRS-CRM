-- Run ONCE in the Supabase SQL Editor after 0001_foundation.sql.
-- 1) Authentication > Users > Add user (tick "Auto confirm"). 2) Put that email below and run.
do $$
declare org uuid; uid uuid; em text := 'YOUR-EMAIL@example.com'; nm text := 'Your Name'; ag text := 'Your Agency Name';
begin
  select id into uid from auth.users where email = em;
  if uid is null then raise exception 'Create the user in Authentication first'; end if;
  insert into organisations (name, slug) values (ag, lower(regexp_replace(ag,'[^a-zA-Z0-9]+','-','g'))) returning id into org;
  insert into users (id, organisation_id, full_name, email) values (uid, org, nm, em);
  insert into user_roles (user_id, organisation_id, role) values (uid, org, 'super_admin');
end $$;
