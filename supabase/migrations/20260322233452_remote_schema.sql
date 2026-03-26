drop extension if exists "pg_net";

create sequence "public"."anime_id_seq";

create sequence "public"."reviews_id_seq";

create sequence "public"."studios_id_seq";


  create table "public"."anime" (
    "id" integer not null default nextval('public.anime_id_seq'::regclass),
    "title" text not null,
    "status" text default 'Plan to Watch'::text,
    "mal_id" integer,
    "anilist_id" integer,
    "studio_id" integer,
    "cover_image_url" text,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "kitsu_id" text,
    "synopsis" text,
    "average_rating" numeric
      );


alter table "public"."anime" enable row level security;


  create table "public"."reviews" (
    "id" integer not null default nextval('public.reviews_id_seq'::regclass),
    "anime_id" integer,
    "rating" integer,
    "review_body" text,
    "youtube_url" text,
    "is_public" boolean default true,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."reviews" enable row level security;


  create table "public"."studios" (
    "id" integer not null default nextval('public.studios_id_seq'::regclass),
    "name" text not null,
    "established_year" integer,
    "api_reference_id" integer
      );


alter table "public"."studios" enable row level security;

alter sequence "public"."anime_id_seq" owned by "public"."anime"."id";

alter sequence "public"."reviews_id_seq" owned by "public"."reviews"."id";

alter sequence "public"."studios_id_seq" owned by "public"."studios"."id";

CREATE UNIQUE INDEX anime_anilist_id_key ON public.anime USING btree (anilist_id);

CREATE UNIQUE INDEX anime_kitsu_id_key ON public.anime USING btree (kitsu_id);

CREATE UNIQUE INDEX anime_mal_id_key ON public.anime USING btree (mal_id);

CREATE UNIQUE INDEX anime_pkey ON public.anime USING btree (id);

CREATE UNIQUE INDEX reviews_pkey ON public.reviews USING btree (id);

CREATE UNIQUE INDEX studios_name_key ON public.studios USING btree (name);

CREATE UNIQUE INDEX studios_pkey ON public.studios USING btree (id);

alter table "public"."anime" add constraint "anime_pkey" PRIMARY KEY using index "anime_pkey";

alter table "public"."reviews" add constraint "reviews_pkey" PRIMARY KEY using index "reviews_pkey";

alter table "public"."studios" add constraint "studios_pkey" PRIMARY KEY using index "studios_pkey";

alter table "public"."anime" add constraint "anime_anilist_id_key" UNIQUE using index "anime_anilist_id_key";

alter table "public"."anime" add constraint "anime_kitsu_id_key" UNIQUE using index "anime_kitsu_id_key";

alter table "public"."anime" add constraint "anime_mal_id_key" UNIQUE using index "anime_mal_id_key";

alter table "public"."anime" add constraint "anime_studio_id_fkey" FOREIGN KEY (studio_id) REFERENCES public.studios(id) not valid;

alter table "public"."anime" validate constraint "anime_studio_id_fkey";

alter table "public"."reviews" add constraint "reviews_anime_id_fkey" FOREIGN KEY (anime_id) REFERENCES public.anime(id) ON DELETE CASCADE not valid;

alter table "public"."reviews" validate constraint "reviews_anime_id_fkey";

alter table "public"."reviews" add constraint "reviews_rating_check" CHECK (((rating >= 1) AND (rating <= 10))) not valid;

alter table "public"."reviews" validate constraint "reviews_rating_check";

alter table "public"."studios" add constraint "studios_name_key" UNIQUE using index "studios_name_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

grant delete on table "public"."anime" to "anon";

grant insert on table "public"."anime" to "anon";

grant references on table "public"."anime" to "anon";

grant select on table "public"."anime" to "anon";

grant trigger on table "public"."anime" to "anon";

grant truncate on table "public"."anime" to "anon";

grant update on table "public"."anime" to "anon";

grant delete on table "public"."anime" to "authenticated";

grant insert on table "public"."anime" to "authenticated";

grant references on table "public"."anime" to "authenticated";

grant select on table "public"."anime" to "authenticated";

grant trigger on table "public"."anime" to "authenticated";

grant truncate on table "public"."anime" to "authenticated";

grant update on table "public"."anime" to "authenticated";

grant delete on table "public"."anime" to "service_role";

grant insert on table "public"."anime" to "service_role";

grant references on table "public"."anime" to "service_role";

grant select on table "public"."anime" to "service_role";

grant trigger on table "public"."anime" to "service_role";

grant truncate on table "public"."anime" to "service_role";

grant update on table "public"."anime" to "service_role";

grant delete on table "public"."reviews" to "anon";

grant insert on table "public"."reviews" to "anon";

grant references on table "public"."reviews" to "anon";

grant select on table "public"."reviews" to "anon";

grant trigger on table "public"."reviews" to "anon";

grant truncate on table "public"."reviews" to "anon";

grant update on table "public"."reviews" to "anon";

grant delete on table "public"."reviews" to "authenticated";

grant insert on table "public"."reviews" to "authenticated";

grant references on table "public"."reviews" to "authenticated";

grant select on table "public"."reviews" to "authenticated";

grant trigger on table "public"."reviews" to "authenticated";

grant truncate on table "public"."reviews" to "authenticated";

grant update on table "public"."reviews" to "authenticated";

grant delete on table "public"."reviews" to "service_role";

grant insert on table "public"."reviews" to "service_role";

grant references on table "public"."reviews" to "service_role";

grant select on table "public"."reviews" to "service_role";

grant trigger on table "public"."reviews" to "service_role";

grant truncate on table "public"."reviews" to "service_role";

grant update on table "public"."reviews" to "service_role";

grant delete on table "public"."studios" to "anon";

grant insert on table "public"."studios" to "anon";

grant references on table "public"."studios" to "anon";

grant select on table "public"."studios" to "anon";

grant trigger on table "public"."studios" to "anon";

grant truncate on table "public"."studios" to "anon";

grant update on table "public"."studios" to "anon";

grant delete on table "public"."studios" to "authenticated";

grant insert on table "public"."studios" to "authenticated";

grant references on table "public"."studios" to "authenticated";

grant select on table "public"."studios" to "authenticated";

grant trigger on table "public"."studios" to "authenticated";

grant truncate on table "public"."studios" to "authenticated";

grant update on table "public"."studios" to "authenticated";

grant delete on table "public"."studios" to "service_role";

grant insert on table "public"."studios" to "service_role";

grant references on table "public"."studios" to "service_role";

grant select on table "public"."studios" to "service_role";

grant trigger on table "public"."studios" to "service_role";

grant truncate on table "public"."studios" to "service_role";

grant update on table "public"."studios" to "service_role";


