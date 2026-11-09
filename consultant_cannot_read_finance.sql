-- Run in the SQL Editor AFTER bootstrap. Creates temporary test data, checks it, then rolls everything back.
-- Expected: every line returns "PASS". Any "FAIL" means stop and tell your developer.
begin;
do $$
declare org uuid; cu uuid := gen_random_uuid(); mu uuid := gen_random_uuid(); n int; ok boolean;
begin
  select id into org from organisations limit 1;
  insert into auth.users (id, email, instance_id, aud, role) values
    (cu,'test-consultant@example.invalid','00000000-0000-0000-0000-000000000000','authenticated','authenticated'),
    (mu,'test-manager@example.invalid','00000000-0000-0000-0000-000000000000','authenticated','authenticated');
  insert into users (id, organisation_id, full_name, email) values (cu, org, 'Test Consultant', 'test-consultant@example.invalid'), (mu, org, 'Test Manager', 'test-manager@example.invalid');
  insert into user_roles values (cu, org, 'consultant'), (mu, org, 'manager');
  insert into pay_rates (organisation_id, assignment_id, rate_per_hour, effective_from) values (org, gen_random_uuid(), 12.50, '2026-01-01');

  perform set_config('request.jwt.claims', json_build_object('sub', cu, 'role', 'authenticated')::text, true);
  set local role authenticated;
  select count(*) into n from pay_rates;
  raise notice '% consultant sees no pay rates', case when n = 0 then 'PASS' else 'FAIL' end;
  begin insert into pay_rates (organisation_id, assignment_id, rate_per_hour, effective_from) values (org, gen_random_uuid(), 1, '2026-01-01'); ok := false;
  exception when others then ok := true; end;
  raise notice '% consultant cannot insert pay rates', case when ok then 'PASS' else 'FAIL' end;
  raise notice '% consultant has no financial access', case when has_financial_access() = false then 'PASS' else 'FAIL' end;

  reset role;
  perform set_config('request.jwt.claims', json_build_object('sub', mu, 'role', 'authenticated')::text, true);
  set local role authenticated;
  raise notice '% manager has no financial access by default', case when has_financial_access() = false then 'PASS' else 'FAIL' end;
  select count(*) into n from pay_rates;
  raise notice '% manager sees no pay rates by default', case when n = 0 then 'PASS' else 'FAIL' end;
  reset role;
end $$;
rollback;
