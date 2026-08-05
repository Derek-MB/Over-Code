-- ================================================================
-- OVER CODE - Base de datos maestra para Supabase (PostgreSQL)
-- Versión: 1.0.0
--
-- Instrucciones:
-- 1. En Supabase abre SQL Editor > New query.
-- 2. Pega TODO este archivo y pulsa Run una sola vez.
-- 3. Luego, en Authentication > Providers, habilita Email.
--
-- Este script puede ejecutarse nuevamente sin borrar el progreso.
-- ================================================================

create extension if not exists pgcrypto;
create extension if not exists citext;

-- ----------------------------------------------------------------
-- Función común: actualiza automáticamente la fecha de modificación.
-- ----------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- ----------------------------------------------------------------
-- Perfil principal. auth.users pertenece a Supabase Authentication;
-- esta tabla contiene únicamente los datos propios de Over Code.
-- ----------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext unique,
  display_name text not null default 'Programador/a',
  avatar text not null default 'boy',
  current_level integer not null default 1 check (current_level >= 1),
  highest_unlocked_level integer not null default 1 check (highest_unlocked_level >= 1),
  experience integer not null default 0 check (experience >= 0),
  progress numeric(5,2) not null default 0 check (progress >= 0 and progress <= 100),
  play_time_seconds bigint not null default 0 check (play_time_seconds >= 0),
  games_played integer not null default 0 check (games_played >= 0),
  attempts integer not null default 0 check (attempts >= 0),
  correct_answers integer not null default 0 check (correct_answers >= 0),
  wrong_answers integer not null default 0 check (wrong_answers >= 0),
  coins integer not null default 0 check (coins >= 0),
  last_login timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (highest_unlocked_level >= current_level),
  check (correct_answers + wrong_answers <= attempts)
);

-- Crea el perfil al registrarse. El juego/web puede mandar
-- display_name, username y avatar dentro de user_metadata.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username, display_name, avatar, last_login)
  values (
    new.id,
    nullif(trim(coalesce(new.raw_user_meta_data ->> 'username', '')), ''),
    coalesce(nullif(trim(coalesce(new.raw_user_meta_data ->> 'display_name', '')), ''), 'Programador/a'),
    coalesce(nullif(trim(coalesce(new.raw_user_meta_data ->> 'avatar', '')), ''), 'boy'),
    timezone('utc', now())
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ----------------------------------------------------------------
-- Catálogo de logros y logros desbloqueados por cada jugador.
-- ----------------------------------------------------------------
create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z0-9_]+$'),
  name text not null,
  description text not null,
  icon_path text,
  category text not null default 'general',
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_achievements (
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  unlocked_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, achievement_id)
);

-- ----------------------------------------------------------------
-- Las tres partidas locales se sincronizan aquí. position, inventory
-- y game_state son JSONB para que el juego evolucione sin migraciones
-- por cada nuevo objeto o propiedad.
-- ----------------------------------------------------------------
create table if not exists public.save_slots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  slot_number smallint not null check (slot_number between 1 and 3),
  slot_name text,
  world_name text not null default 'HTML',
  current_level integer not null default 1 check (current_level >= 1),
  highest_unlocked_level integer not null default 1 check (highest_unlocked_level >= 1),
  play_time_seconds bigint not null default 0 check (play_time_seconds >= 0),
  game_version text not null default '1.0.0',
  player_position jsonb not null default '{"x": 0, "y": 0}'::jsonb,
  inventory jsonb not null default '[]'::jsonb,
  game_state jsonb not null default '{}'::jsonb,
  sync_version integer not null default 1 check (sync_version >= 1),
  last_played_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, slot_number),
  check (highest_unlocked_level >= current_level)
);

-- Una fila por jugador con métricas que no forman parte directamente
-- de su perfil. La precisión se calcula desde las respuestas.
create table if not exists public.statistics (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  enemies_defeated integer not null default 0 check (enemies_defeated >= 0),
  levels_completed integer not null default 0 check (levels_completed >= 0),
  hints_used integer not null default 0 check (hints_used >= 0),
  mentor_questions integer not null default 0 check (mentor_questions >= 0),
  topics_mastered jsonb not null default '[]'::jsonb,
  topics_to_practice jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default timezone('utc', now())
);

-- Versiones publicadas que el juego consulta al iniciar.
create table if not exists public.game_versions (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  release_notes text not null default '',
  download_url text,
  is_current boolean not null default false,
  published_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now())
);

-- Tabla pública y limitada para el ranking. No contiene correo,
-- partidas, inventario ni otros datos privados del perfil.
create table if not exists public.leaderboard_entries (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  username text not null,
  display_name text not null,
  avatar text not null,
  current_level integer not null,
  highest_unlocked_level integer not null,
  experience integer not null,
  progress numeric(5,2) not null,
  achievement_count integer not null default 0,
  ranking_score numeric(12,2) not null default 0,
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists one_current_game_version
  on public.game_versions (is_current) where is_current;
create index if not exists profiles_ranking_index
  on public.profiles (progress desc, experience desc, highest_unlocked_level desc);
create index if not exists save_slots_user_updated_index
  on public.save_slots (user_id, updated_at desc);
create index if not exists user_achievements_user_index
  on public.user_achievements (user_id);

-- Recalcula la fila pública del ranking al cambiar el perfil o logros.
create or replace function public.refresh_leaderboard_entry(target_user_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.leaderboard_entries (
    user_id, username, display_name, avatar, current_level,
    highest_unlocked_level, experience, progress, achievement_count,
    ranking_score, updated_at
  )
  select
    p.id,
    coalesce(p.username::text, p.display_name),
    p.display_name,
    p.avatar,
    p.current_level,
    p.highest_unlocked_level,
    p.experience,
    p.progress,
    count(ua.achievement_id)::integer,
    round(
      (p.progress * 10) + (p.experience * 0.50)
      + (p.highest_unlocked_level * 50) + (count(ua.achievement_id) * 100),
      2
    ),
    timezone('utc', now())
  from public.profiles p
  left join public.user_achievements ua on ua.user_id = p.id
  where p.id = target_user_id
  group by p.id
  on conflict (user_id) do update set
    username = excluded.username,
    display_name = excluded.display_name,
    avatar = excluded.avatar,
    current_level = excluded.current_level,
    highest_unlocked_level = excluded.highest_unlocked_level,
    experience = excluded.experience,
    progress = excluded.progress,
    achievement_count = excluded.achievement_count,
    ranking_score = excluded.ranking_score,
    updated_at = excluded.updated_at;
end;
$$;

create or replace function public.refresh_leaderboard_from_profile()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  perform public.refresh_leaderboard_entry(new.id);
  return new;
end;
$$;

create or replace function public.refresh_leaderboard_from_achievement()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.refresh_leaderboard_entry(old.user_id);
    return old;
  end if;
  perform public.refresh_leaderboard_entry(new.user_id);
  return new;
end;
$$;

drop trigger if exists profiles_refresh_leaderboard on public.profiles;
create trigger profiles_refresh_leaderboard
  after insert or update of username, display_name, avatar, current_level,
  highest_unlocked_level, experience, progress on public.profiles
  for each row execute procedure public.refresh_leaderboard_from_profile();

drop trigger if exists achievements_refresh_leaderboard on public.user_achievements;
create trigger achievements_refresh_leaderboard
  after insert or delete on public.user_achievements
  for each row execute procedure public.refresh_leaderboard_from_achievement();

-- Sincroniza los perfiles que ya existían antes de este script.
insert into public.leaderboard_entries (
  user_id, username, display_name, avatar, current_level,
  highest_unlocked_level, experience, progress, achievement_count,
  ranking_score, updated_at
)
select
  p.id, coalesce(p.username::text, p.display_name), p.display_name, p.avatar,
  p.current_level, p.highest_unlocked_level, p.experience, p.progress,
  count(ua.achievement_id)::integer,
  round((p.progress * 10) + (p.experience * 0.50)
    + (p.highest_unlocked_level * 50) + (count(ua.achievement_id) * 100), 2),
  p.updated_at
from public.profiles p
left join public.user_achievements ua on ua.user_id = p.id
group by p.id
on conflict (user_id) do update set
  username = excluded.username,
  display_name = excluded.display_name,
  avatar = excluded.avatar,
  current_level = excluded.current_level,
  highest_unlocked_level = excluded.highest_unlocked_level,
  experience = excluded.experience,
  progress = excluded.progress,
  achievement_count = excluded.achievement_count,
  ranking_score = excluded.ranking_score,
  updated_at = excluded.updated_at;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

drop trigger if exists save_slots_set_updated_at on public.save_slots;
create trigger save_slots_set_updated_at
  before update on public.save_slots
  for each row execute procedure public.set_updated_at();

drop trigger if exists statistics_set_updated_at on public.statistics;
create trigger statistics_set_updated_at
  before update on public.statistics
  for each row execute procedure public.set_updated_at();

-- Crea las estadísticas vacías junto al perfil.
create or replace function public.create_initial_statistics()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.statistics (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_profile_created on public.profiles;
create trigger on_profile_created
  after insert on public.profiles
  for each row execute procedure public.create_initial_statistics();

-- ----------------------------------------------------------------
-- Ranking: se calcula en tiempo real, sin duplicar datos en una tabla.
-- La puntuación mezcla progreso, experiencia, nivel y logros.
-- Solo publica los campos seguros para el ranking.
-- ----------------------------------------------------------------
-- La vista anterior solo es una consulta guardada; se elimina para poder
-- actualizar el formato de ranking_score sin afectar ningún dato.
drop view if exists public.leaderboard;

create view public.leaderboard
with (security_invoker = true)
as
select
  row_number() over (order by ranking_score desc, updated_at asc) as rank,
  user_id, username, display_name, avatar, current_level,
  highest_unlocked_level, experience, progress, achievement_count, ranking_score
from public.leaderboard_entries;

-- ----------------------------------------------------------------
-- Seguridad de Supabase (RLS). Nunca se usa la service_role key en
-- Godot ni en el navegador: esa clave solo debe existir en un servidor.
-- ----------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.save_slots enable row level security;
alter table public.statistics enable row level security;
alter table public.game_versions enable row level security;
alter table public.leaderboard_entries enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

drop policy if exists "achievements_read_active" on public.achievements;
create policy "achievements_read_active" on public.achievements
  for select to authenticated using (active = true);

drop policy if exists "user_achievements_own" on public.user_achievements;
create policy "user_achievements_own" on public.user_achievements
  for all to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "save_slots_own" on public.save_slots;
create policy "save_slots_own" on public.save_slots
  for all to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "statistics_own" on public.statistics;
create policy "statistics_own" on public.statistics
  for all to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "game_versions_read" on public.game_versions;
create policy "game_versions_read" on public.game_versions
  for select to authenticated using (true);

drop policy if exists "leaderboard_public_read" on public.leaderboard_entries;
create policy "leaderboard_public_read" on public.leaderboard_entries
  for select to anon, authenticated using (true);

grant usage on schema public to anon, authenticated;
grant select on public.leaderboard to anon, authenticated;
grant select on public.game_versions to anon, authenticated;
grant select on public.leaderboard_entries to anon, authenticated;
grant select, update on public.profiles to authenticated;
grant select on public.achievements to authenticated;
grant select, insert, update, delete on public.user_achievements to authenticated;
grant select, insert, update, delete on public.save_slots to authenticated;
grant select, insert, update, delete on public.statistics to authenticated;

-- Datos iniciales mínimos (ejemplo). Puedes cambiarlos desde la tabla.
insert into public.game_versions (version, release_notes, is_current)
values ('1.0.0', 'Primera versión de Over Code.', true)
on conflict (version) do nothing;

insert into public.achievements (code, name, description, icon_path, category, sort_order)
values
  ('first_steps', 'Primeros pasos', 'Completa tu primer nivel.', 'res://Sprites/achievements/first_steps.png', 'progreso', 1),
  ('html_explorer', 'Explorador HTML', 'Completa el mundo de HTML.', 'res://Sprites/achievements/html_explorer.png', 'progreso', 2),
  ('perfect_answer', 'Respuesta perfecta', 'Responde correctamente sin fallos.', 'res://Sprites/achievements/perfect_answer.png', 'habilidad', 3)
on conflict (code) do nothing;

-- FIN. Para comprobar que se creó correctamente ejecuta después:
-- select * from public.leaderboard;
