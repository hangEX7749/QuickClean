-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT now(),
  user_id uuid NOT NULL,
  service_type text NOT NULL,
  property_size text,
  booking_date date NOT NULL,
  booking_time time without time zone NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'completed'::text, 'cancelled'::text])),
  total_price numeric,
  notes text,
  provider_id uuid,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.service_providers(id),
  CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.cache (
  key character varying NOT NULL,
  value text NOT NULL,
  expiration integer NOT NULL,
  CONSTRAINT cache_pkey PRIMARY KEY (key)
);
CREATE TABLE public.cache_locks (
  key character varying NOT NULL,
  owner character varying NOT NULL,
  expiration integer NOT NULL,
  CONSTRAINT cache_locks_pkey PRIMARY KEY (key)
);
CREATE TABLE public.failed_jobs (
  id bigint NOT NULL DEFAULT nextval('failed_jobs_id_seq'::regclass),
  uuid character varying NOT NULL UNIQUE,
  connection text NOT NULL,
  queue text NOT NULL,
  payload text NOT NULL,
  exception text NOT NULL,
  failed_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT failed_jobs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.job_batches (
  id character varying NOT NULL,
  name character varying NOT NULL,
  total_jobs integer NOT NULL,
  pending_jobs integer NOT NULL,
  failed_jobs integer NOT NULL,
  failed_job_ids text NOT NULL,
  options text,
  cancelled_at integer,
  created_at integer NOT NULL,
  finished_at integer,
  CONSTRAINT job_batches_pkey PRIMARY KEY (id)
);
CREATE TABLE public.jobs (
  id bigint NOT NULL DEFAULT nextval('jobs_id_seq'::regclass),
  queue character varying NOT NULL,
  payload text NOT NULL,
  attempts smallint NOT NULL,
  reserved_at integer,
  available_at integer NOT NULL,
  created_at integer NOT NULL,
  CONSTRAINT jobs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.member (
  id uuid NOT NULL,
  email text,
  name text,
  role text DEFAULT 'member'::text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT member_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.migrations (
  id integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass),
  migration character varying NOT NULL,
  batch integer NOT NULL,
  CONSTRAINT migrations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.password_reset_tokens (
  email character varying NOT NULL,
  token character varying NOT NULL,
  created_at timestamp without time zone,
  CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email)
);
CREATE TABLE public.service_provider_pivot (
  service_id uuid NOT NULL,
  provider_id uuid NOT NULL,
  CONSTRAINT service_provider_pivot_pkey PRIMARY KEY (service_id, provider_id),
  CONSTRAINT service_provider_pivot_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id),
  CONSTRAINT service_provider_pivot_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.service_providers(id)
);
CREATE TABLE public.service_providers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  specialty text,
  rating numeric DEFAULT 5.0,
  is_available boolean DEFAULT true,
  image_url text,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT service_providers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.services (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  name text NOT NULL,
  image_url text,
  price numeric DEFAULT 0,
  description text,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT services_pkey PRIMARY KEY (id)
);
CREATE TABLE public.sessions (
  id character varying NOT NULL,
  ip_address character varying,
  user_agent text,
  payload text NOT NULL,
  last_activity integer NOT NULL,
  user_id uuid,
  CONSTRAINT sessions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  password character varying,
  role character varying DEFAULT 'authenticated'::character varying,
  remember_token character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  username text UNIQUE,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);