drop table users;
drop table habits;
drop table friendships;

/**
* USERS
* Note: This table contains user data. Users data can be seen by everyone but can only be updated by the user.
*/
create table users (
  -- UUID from auth.users
  id uuid references auth.users not null primary key,
  username text
);
alter table users enable row level security;
create policy "User data can be viewed by everyone." on users for select using (true);
create policy "User data can only be updated by the user." on users for update using (auth.uid() = id);
create policy "User data can be inserted by the user." on users for insert with check (auth.uid() = id);

/**
* HABITS
* Note: This table contains habits data. habits are visible by everyone but can only be updated by the user who created them.
*/
create table habits (
  id serial primary key,
  name text,
  description text,
  user_id uuid references auth.users not null,
  streak integer
);
alter table habits enable row level security;
create policy "Habits can be viewed by everyone." on habits for select using (true);
create policy "Habits can only be updated by the user who created them." on habits for update using (auth.uid() = user_id);
create policy "Habits can be inserted by the user who created them." on habits with check (auth.uid() = user_id);

/**
* FRIENDSHIPS
* Note: This table contains friendships data. friendships are visible by everyone but can only be updated by the user who created them.
*/
create table friendships (
  id serial primary key,
  user_id uuid references auth.users not null,
  friend_id uuid references auth.users not null
);

alter table friendships enable row level security;
create policy "Friendships can be viewed by everyone." on friendships for select using (true);
create policy "Friendships can only be updated by the user who created them." on friendships for update using (auth.uid() = user_id);
create policy "Friendships can be inserted by the user who created them." on friendships with check (auth.uid() = user_id);

