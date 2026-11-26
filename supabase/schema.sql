-- Ejecuta este script en Supabase > SQL Editor > New query.

-- Objetivos diarios de cada usuario (una fila por usuario)
create table if not exists public.goals (
  user_id    uuid primary key default auth.uid() references auth.users on delete cascade,
  kcal       integer not null default 3500 check (kcal >= 0),
  protein    integer not null default 175  check (protein >= 0),
  carbs      integer not null default 480  check (carbs >= 0),
  fat        integer not null default 95   check (fat >= 0),
  updated_at timestamptz not null default now()
);

-- Cada alimento apuntado
create table if not exists public.food_items (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  day        date not null,
  meal       text not null check (meal in ('Desayuno','Media mañana','Comida','Merienda','Cena','Snack')),
  name       text not null check (char_length(name) <= 80),
  quantity   text not null default '' check (char_length(quantity) <= 80),
  kcal       integer not null default 0 check (kcal >= 0),
  protein    integer not null default 0 check (protein >= 0),
  carbs      integer not null default 0 check (carbs >= 0),
  fat        integer not null default 0 check (fat >= 0),
  created_at timestamptz not null default now()
);

create index if not exists food_items_user_day on public.food_items (user_id, day);

-- Seguridad: cada usuario solo ve y modifica sus propias filas
alter table public.goals      enable row level security;
alter table public.food_items enable row level security;

drop policy if exists "goals: solo el dueño" on public.goals;
create policy "goals: solo el dueño" on public.goals
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "food_items: solo el dueño" on public.food_items;
create policy "food_items: solo el dueño" on public.food_items
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
