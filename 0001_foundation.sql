create extension if not exists pgcrypto;
create extension if not exists btree_gist;

create table organisations (id uuid primary key default gen_random_uuid(), name text not null, slug text unique not null,
  settings jsonb not null default '{}', created_at timestamptz not null default now());
create table users (id uuid primary key references auth.users(id) on delete cascade,
  organisation_id uuid not null references organisations(id), full_name text not null, email text not null,
  active boolean not null default true, created_at timestamptz not null default now());
create index on users (organisation_id);
create type app_role as enum ('consultant','manager','super_admin');
create table user_roles (user_id uuid primary key references users(id) on delete cascade,
  organisation_id uuid not null references organisations(id), role app_role not null default 'consultant');
create table user_permissions (user_id uuid not null references users(id) on delete cascade,
  organisation_id uuid not null references organisations(id), permission text not null,
  granted boolean not null default false, primary key (user_id, permission));

create or replace function current_org_id() returns uuid language sql stable security definer set search_path = public as
$$ select organisation_id from users where id = auth.uid() and active $$;
create or replace function current_role_name() returns app_role language sql stable security definer set search_path = public as
$$ select r.role from user_roles r join users u on u.id = r.user_id and u.active where r.user_id = auth.uid() $$;
create or replace function has_financial_access() returns boolean language sql stable security definer set search_path = public as
$$ select coalesce((select r.role = 'super_admin' or (r.role = 'manager' and exists (
     select 1 from user_permissions p where p.user_id = r.user_id and p.permission = 'financial_access' and p.granted))
   from user_roles r join users u on u.id = r.user_id and u.active where r.user_id = auth.uid()), false) $$;

create table audit_logs (id bigint generated always as identity primary key,
  organisation_id uuid not null references organisations(id), actor_id uuid references users(id), action text not null,
  entity_type text, entity_id uuid, before jsonb, after jsonb, created_at timestamptz not null default now());
create index on audit_logs (organisation_id, created_at desc);

create table pay_rates (id uuid primary key default gen_random_uuid(), organisation_id uuid not null references organisations(id),
  assignment_id uuid not null, rate_per_hour numeric(10,2) not null check (rate_per_hour >= 0),
  effective_from date not null, effective_to date, entered_by uuid references users(id), created_at timestamptz not null default now(),
  check (effective_to is null or effective_to >= effective_from),
  exclude using gist (assignment_id with =, daterange(effective_from, coalesce(effective_to,'infinity'),'[]') with &&));
create table charge_rates (like pay_rates including all);
create table employment_costs (id uuid primary key default gen_random_uuid(), organisation_id uuid not null references organisations(id),
  assignment_id uuid, cost_type text not null check (cost_type in ('employer_ni','holiday_pay','pension','other')),
  calc_method text not null check (calc_method in ('percent','fixed_per_hour')), value numeric(10,4) not null check (value >= 0),
  effective_from date not null, effective_to date, created_at timestamptz not null default now());

alter table organisations enable row level security; alter table users enable row level security;
alter table user_roles enable row level security; alter table user_permissions enable row level security;
alter table audit_logs enable row level security; alter table pay_rates enable row level security;
alter table charge_rates enable row level security; alter table employment_costs enable row level security;

create policy org_read on organisations for select using (id = current_org_id());
create policy users_read on users for select using (organisation_id = current_org_id());
create policy users_admin_write on users for all using (organisation_id = current_org_id() and current_role_name() = 'super_admin')
  with check (organisation_id = current_org_id() and current_role_name() = 'super_admin');
create policy roles_read on user_roles for select using (organisation_id = current_org_id() and (user_id = auth.uid() or current_role_name() = 'super_admin'));
create policy roles_admin_write on user_roles for all using (organisation_id = current_org_id() and current_role_name() = 'super_admin')
  with check (organisation_id = current_org_id() and current_role_name() = 'super_admin');
create policy perms_read on user_permissions for select using (organisation_id = current_org_id() and (user_id = auth.uid() or current_role_name() = 'super_admin'));
create policy perms_admin_write on user_permissions for all using (organisation_id = current_org_id() and current_role_name() = 'super_admin')
  with check (organisation_id = current_org_id() and current_role_name() = 'super_admin');
create policy audit_admin_read on audit_logs for select using (organisation_id = current_org_id() and current_role_name() = 'super_admin');
create policy audit_insert on audit_logs for insert with check (organisation_id = current_org_id());
create policy pay_rates_fin on pay_rates for all using (organisation_id = current_org_id() and has_financial_access())
  with check (organisation_id = current_org_id() and has_financial_access());
create policy charge_rates_fin on charge_rates for all using (organisation_id = current_org_id() and has_financial_access())
  with check (organisation_id = current_org_id() and has_financial_access());
create policy employment_costs_fin on employment_costs for all using (organisation_id = current_org_id() and has_financial_access())
  with check (organisation_id = current_org_id() and has_financial_access());
