-- **********************************************************************************************
-- Migration: 20250411145523_create_10xcards_schema.sql
-- Purpose: Create database schema for 10xCards application
-- Tables: flashcards, learning_sessions, flashcard_repetitions
-- Functions: calculate_next_review_date, get_flashcards_for_learning
-- Triggers: trigger_set_timestamp, update_learning_session_stats
-- **********************************************************************************************

-- Enable uuid-ossp extension for UUID generation
create extension if not exists "uuid-ossp";

-- Enable text search extension for GIN index
create extension if not exists pg_trgm;

-- **********************************************************************************************
-- Table: flashcards
-- Stores information about flashcards created by users
-- **********************************************************************************************
create table if not exists flashcards (
                                          id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    front_content varchar(200) not null check (length(front_content) <= 200),
    back_content varchar(500) not null check (length(back_content) <= 500),
    creation_method varchar(10) not null check (creation_method in ('manual', 'ai', 'ai_edited')) default 'manual',
    is_deleted boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
    );

-- Indexes for flashcards table
create index idx_flashcards_user_id on flashcards(user_id);
create index idx_flashcards_is_deleted on flashcards(is_deleted);
create index idx_flashcards_front_content on flashcards using gin (front_content gin_trgm_ops);

-- **********************************************************************************************
-- Table: learning_sessions
-- Stores information about user learning sessions
-- **********************************************************************************************
create table if not exists learning_sessions (
                                                 id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    start_time timestamptz not null default now(),
    finished_time timestamptz default null,
    cards_reviewed integer not null default 0,
    avg_score numeric(2,1) default null
    );

-- Indexes for learning_sessions table
create index idx_learning_sessions_user_id on learning_sessions(user_id);

-- **********************************************************************************************
-- Table: flashcard_repetitions
-- Stores history of flashcard repetitions
-- **********************************************************************************************
create table if not exists flashcard_repetitions (
                                                     id uuid primary key default uuid_generate_v4(),
    flashcard_id uuid not null references flashcards(id) on delete cascade,
    session_id uuid not null references learning_sessions(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,
    score integer not null check (score between 1 and 5),
    review_date timestamptz not null default now(),
    next_review_date timestamptz not null
    );

-- Indexes for flashcard_repetitions table
create index idx_flashcard_repetitions_user_next_review on flashcard_repetitions(user_id, next_review_date);
create index idx_flashcard_repetitions_flashcard_id on flashcard_repetitions(flashcard_id);
create index idx_flashcard_repetitions_session_id on flashcard_repetitions(session_id);

-- **********************************************************************************************
-- Function: calculate_next_review_date
-- Implements spaced repetition algorithm to calculate the next review date
-- **********************************************************************************************
create or replace function calculate_next_review_date(score integer)
returns timestamptz as $$
declare
next_date timestamptz;
begin
case score
    when 1 then next_date := now() + interval '2 days';
when 2 then next_date := now() + interval '3 days';
when 3 then next_date := now() + interval '5 days';
when 4 then next_date := now() + interval '7 days';
when 5 then next_date := now() + interval '14 days';
else next_date := now() + interval '1 day';
end case;

return next_date;
end;
$$ language plpgsql;

-- **********************************************************************************************
-- Function and trigger: trigger_set_timestamp
-- Updates the updated_at field whenever a flashcard is modified
-- **********************************************************************************************
create or replace function trigger_set_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
return new;
end;
$$ language plpgsql;

create trigger trigger_set_timestamp
    before update on flashcards
    for each row
    execute function trigger_set_timestamp();

-- **********************************************************************************************
-- Function and trigger: update_learning_session_stats
-- Updates session statistics after each new repetition
-- **********************************************************************************************
create or replace function update_learning_session_stats()
returns trigger as $$
begin
  -- Increment reviewed cards counter
update learning_sessions
set
    cards_reviewed = cards_reviewed + 1,
    finished_time = now()
where id = new.session_id;

-- Update average score
update learning_sessions
set avg_score = (
    select avg(score)::numeric(2,1)
    from flashcard_repetitions
    where session_id = new.session_id
)
where id = new.session_id;

return new;
end;
$$ language plpgsql;

create trigger trigger_update_learning_session_stats
    after insert on flashcard_repetitions
    for each row
    execute function update_learning_session_stats();

-- **********************************************************************************************
-- Function: get_flashcards_for_learning
-- Retrieves flashcards for learning (overdue + new)
-- **********************************************************************************************
create or replace function get_flashcards_for_learning(
  p_user_id uuid,
  p_new_cards_count integer default 5
)
returns table (
  id uuid,
  front_content varchar(200),
  back_content varchar(500),
  is_review boolean
) as $$
begin
  -- Get flashcards for review
return query
select distinct on (f.id)
    f.id,
    f.front_content,
    f.back_content,
    true as is_review
from flashcards f
    join flashcard_repetitions fr on f.id = fr.flashcard_id
where f.user_id = p_user_id
  and f.is_deleted = false
  and fr.next_review_date <= now()
  and fr.user_id = p_user_id
order by f.id, fr.next_review_date desc;

-- Get new flashcards (without any repetitions yet)
return query
select
    f.id,
    f.front_content,
    f.back_content,
    false as is_review
from flashcards f
where f.user_id = p_user_id
  and f.is_deleted = false
  and not exists (
    select 1 from flashcard_repetitions fr
    where fr.flashcard_id = f.id
)
order by random()
    limit p_new_cards_count;
end;
$$ language plpgsql;

-- **********************************************************************************************
-- Row Level Security (RLS)
-- Securing tables so users can only access their own data
-- **********************************************************************************************

-- Enable RLS for flashcards table
alter table flashcards enable row level security;

-- Policies for flashcards table
create policy flashcards_select_policy
  on flashcards for select
                               using (auth.uid() = user_id);

create policy flashcards_insert_policy
  on flashcards for insert
  with check (auth.uid() = user_id);

create policy flashcards_update_policy
  on flashcards for update
                                      using (auth.uid() = user_id);

create policy flashcards_delete_policy
  on flashcards for update
                               using (auth.uid() = user_id AND is_deleted = false);

-- Enable RLS for learning_sessions table
alter table learning_sessions enable row level security;

-- Policies for learning_sessions table
create policy learning_sessions_select_policy
  on learning_sessions for select
                                      using (auth.uid() = user_id);

create policy learning_sessions_insert_policy
  on learning_sessions for insert
  with check (auth.uid() = user_id);

create policy learning_sessions_update_policy
  on learning_sessions for update
                                             using (auth.uid() = user_id);

-- Enable RLS for flashcard_repetitions table
alter table flashcard_repetitions enable row level security;

-- Policies for flashcard_repetitions table
create policy flashcard_repetitions_select_policy
  on flashcard_repetitions for select
                                          using (auth.uid() = user_id);

create policy flashcard_repetitions_insert_policy
  on flashcard_repetitions for insert
  with check (auth.uid() = user_id);

create policy flashcard_repetitions_update_policy
  on flashcard_repetitions for update
                                                 using (auth.uid() = user_id);