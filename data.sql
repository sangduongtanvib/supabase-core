
-- --- CÁCH 1 ----
-- -- Tạo schema nếu chưa tồn tại
-- CREATE SCHEMA IF NOT EXISTS auth;
-- CREATE SCHEMA IF NOT EXISTS storage;

-- -- Tạo bảng auth.users giả (chỉ dùng cho local dev nếu Supabase Auth chưa tạo schema auth.users)
-- -- Nếu bạn chạy Supabase Auth container, bạn có thể bỏ phần này
-- CREATE TABLE IF NOT EXISTS auth.users (
--   id uuid PRIMARY KEY
-- );

-- -- Tạo bảng profiles
-- CREATE TABLE IF NOT EXISTS profiles (
--   id uuid REFERENCES auth.users(id) NOT NULL,
--   updated_at timestamp with time zone,
--   username text UNIQUE,
--   avatar_url text,
--   website text,

--   PRIMARY KEY (id),
--   CONSTRAINT username_length CHECK (char_length(username) >= 3)
-- );

-- -- Bật Row Level Security (RLS)
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- -- Policies cho profiles
-- CREATE POLICY "Public profiles are viewable by the owner."
--   ON profiles FOR SELECT
--   USING (auth.uid() = id);

-- CREATE POLICY "Users can insert their own profile."
--   ON profiles FOR INSERT
--   WITH CHECK (auth.uid() = id);

-- CREATE POLICY "Users can update own profile."
--   ON profiles FOR UPDATE
--   USING (auth.uid() = id);

-- -- Cấu hình Realtime
-- BEGIN;
--   DROP PUBLICATION IF EXISTS supabase_realtime;
--   CREATE PUBLICATION supabase_realtime;
-- COMMIT;

-- ALTER PUBLICATION supabase_realtime ADD TABLE profiles;

-- -- Tạo bucket avatars cho Supabase Storage
-- INSERT INTO storage.buckets (id, name)
-- VALUES ('avatars', 'avatars')
-- ON CONFLICT (id) DO NOTHING;

-- -- Policies cho storage.objects (Supabase Storage)
-- CREATE POLICY "Avatar images are publicly accessible."
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'avatars');

-- CREATE POLICY "Anyone can upload an avatar."
--   ON storage.objects FOR INSERT
--   WITH CHECK (bucket_id = 'avatars');

-- CREATE POLICY "Anyone can update an avatar."
--   ON storage.objects FOR UPDATE
--   WITH CHECK (bucket_id = 'avatars');



create table profiles (
  id uuid references auth.users not null,
  updated_at timestamp with time zone,
  username text unique,
  avatar_url text,
  website text,

  primary key (id),
  unique(username),
  constraint username_length check (char_length(username) >= 3)
);

alter table profiles enable row level security;

create policy "Public profiles are viewable by the owner."
  on profiles for select
  using ( auth.uid() = id );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Set up Realtime
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table profiles;

-- Set up Storage
insert into storage.buckets (id, name)
values ('avatars', 'avatars');

create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

create policy "Anyone can upload an avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' );

create policy "Anyone can update an avatar."
  on storage.objects for update
  with check ( bucket_id = 'avatars' );


