-- Migration: Create otp_verifications table for Custom OTP Verification
-- Created At: 2026-06-21

create table if not exists public.otp_verifications (
  id uuid default gen_random_uuid() primary key,
  email text not null,
  otp_code varchar(6) not null,
  purpose text not null check (purpose in ('signup', 'reset')),
  expires_at timestamp with time zone not null,
  is_verified boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.otp_verifications enable row level security;

-- Helper function to check if an email exists in auth.users securely
create or replace function public.check_user_exists(email_to_check text)
returns boolean
security definer
set search_path = public
language plpgsql
as $$
begin
  return exists (
    select 1 from auth.users where email = lower(trim(email_to_check))
  );
end;
$$;

-- Helper function to confirm user email securely
create or replace function public.confirm_user_email(email_to_confirm text)
returns boolean
security definer
set search_path = public
language plpgsql
as $$
begin
  update auth.users
  set email_confirmed_at = now(),
      confirmed_at = now(),
      updated_at = now()
  where email = lower(trim(email_to_confirm));
  return found;
end;
$$;

-- Helper function to retrieve user ID by email securely
create or replace function public.get_user_id_by_email(email_to_find text)
returns uuid
security definer
set search_path = public
language plpgsql
as $$
begin
  return (
    select id from auth.users where email = lower(trim(email_to_find)) limit 1
  );
end;
$$;

-- Do not create public policies since all operations (insert, select, update) 
-- are performed securely from Edge Functions using the service_role key.


