-- OVER CODE - Corrección segura del ranking
-- Ejecutar UNA vez en Supabase > SQL Editor.
-- No borra perfiles, partidas, logros ni estadísticas.

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
    p.id, coalesce(p.username::text, p.display_name), p.display_name, p.avatar,
    p.current_level, p.highest_unlocked_level, p.experience, p.progress,
    count(ua.achievement_id)::integer,
    round((p.progress * 10) + (p.experience * 0.50)
      + (p.highest_unlocked_level * 50) + (count(ua.achievement_id) * 100), 2),
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

alter table public.leaderboard_entries enable row level security;
drop policy if exists "leaderboard_public_read" on public.leaderboard_entries;
create policy "leaderboard_public_read" on public.leaderboard_entries
  for select to anon, authenticated using (true);

grant select on public.leaderboard_entries to anon, authenticated;
grant select on public.leaderboard to anon, authenticated;
