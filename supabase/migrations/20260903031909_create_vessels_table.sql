-- Vessel master data.
--
-- One row per physical ship. Vessel particulars change rarely, so this table is
-- referenced by the operational tables (nominations, port calls, PDAs) rather
-- than duplicating the particulars on every port call.

-- Broad IMO ship-type groupings, kept coarse on purpose: the port agency
-- workflow only needs enough to pick tariffs and required documents.
create type public.vessel_type as enum (
  'bulk_carrier',
  'general_cargo',
  'container',
  'oil_tanker',
  'chemical_tanker',
  'lng_carrier',
  'lpg_carrier',
  'ro_ro',
  'vehicle_carrier',
  'passenger',
  'reefer',
  'tug',
  'offshore',
  'other'
);

create table public.vessels (
  id uuid primary key default gen_random_uuid(),

  -- IMO number is the vessel's permanent identity: it survives renames, reflags
  -- and sales, which is exactly why it is the natural key here. Nullable because
  -- small craft (tugs, barges) are not always IMO-registered.
  imo text unique
    constraint vessels_imo_format check (imo ~ '^[0-9]{7}$'),

  name text not null
    constraint vessels_name_not_blank check (length(btrim(name)) > 0),

  -- MMSI is reassigned when a vessel reflags, so it identifies the current
  -- radio station rather than the hull. Unique at any point in time.
  mmsi text unique
    constraint vessels_mmsi_format check (mmsi ~ '^[0-9]{9}$'),
  call_sign text,

  -- Flag state as ISO 3166-1 alpha-2, uppercased.
  flag text
    constraint vessels_flag_format check (flag ~ '^[A-Z]{2}$'),

  vessel_type public.vessel_type,

  -- Tonnages: DWT drives mooring fees and cargo capacity, GT/NT drive port dues.
  dwt numeric(12, 2) constraint vessels_dwt_non_negative check (dwt >= 0),
  gross_tonnage numeric(12, 2) constraint vessels_gt_non_negative check (gross_tonnage >= 0),
  net_tonnage numeric(12, 2) constraint vessels_nt_non_negative check (net_tonnage >= 0),

  -- Dimensions in metres. Summer draft; the arrival draft belongs on the port call.
  loa_m numeric(7, 2) constraint vessels_loa_positive check (loa_m > 0),
  beam_m numeric(7, 2) constraint vessels_beam_positive check (beam_m > 0),
  draft_m numeric(6, 2) constraint vessels_draft_positive check (draft_m > 0),

  year_built smallint
    constraint vessels_year_built_range check (year_built between 1850 and 2100),

  -- Registered owner and commercial operator, free text until there is a
  -- companies table to point at.
  owner text,
  operator text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.vessels is 'Vessel particulars (master data), keyed on IMO number.';
comment on column public.vessels.imo is 'IMO number: 7 digits, permanent across renames and reflags.';
comment on column public.vessels.mmsi is 'MMSI: 9 digits, reassigned on reflag.';
comment on column public.vessels.flag is 'Flag state as ISO 3166-1 alpha-2.';
comment on column public.vessels.draft_m is 'Summer draft in metres; arrival draft is per port call.';

-- Lookups are by IMO (covered by the unique index) or by name while typing on a
-- nomination, so index the case-insensitive name too.
create index vessels_name_lower_idx on public.vessels (lower(name));
create index vessels_vessel_type_idx on public.vessels (vessel_type);
create index vessels_flag_idx on public.vessels (flag);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger vessels_set_updated_at
  before update on public.vessels
  for each row
  execute function public.set_updated_at();

alter table public.vessels enable row level security;

-- Vessel particulars are reference data shared by everyone in the agency: any
-- signed-in user may read and maintain them. Anonymous access is denied.
create policy "Authenticated users can read vessels"
  on public.vessels for select
  to authenticated
  using (true);

create policy "Authenticated users can insert vessels"
  on public.vessels for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update vessels"
  on public.vessels for update
  to authenticated
  using (true)
  with check (true);

create policy "Authenticated users can delete vessels"
  on public.vessels for delete
  to authenticated
  using (true);
