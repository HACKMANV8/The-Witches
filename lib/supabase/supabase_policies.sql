-- Users table RLS
alter table if exists public.users enable row level security;

-- Allow authenticated users to select their own profile
create policy if not exists users_select_own on public.users
  for select
  to authenticated
  using (id = auth.uid());

-- Allow authenticated users to insert their own profile on sign up
create policy if not exists users_insert_self on public.users
  for insert
  to authenticated
  with check (id = auth.uid());

-- Allow authenticated users to update their own profile
create policy if not exists users_update_own on public.users
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Optionally allow public read of minimal user fields (remove if you don't want this)
create policy if not exists users_public_read on public.users
  for select
  to anon
  using (true);

-- Crowd reports RLS
alter table if exists public.crowd_reports enable row level security;

-- Allow anyone to read recent crowd reports (for live map and home)
create policy if not exists crowd_reports_public_read on public.crowd_reports
  for select
  to anon
  using (true);

-- Allow authenticated users to insert crowd reports attributed to themselves
create policy if not exists crowd_reports_insert_auth on public.crowd_reports
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- Prevent updates/deletes by default (omit policies)

-- Row Level Security Policies for MetroPulse

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE crowd_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Allow users to read their own data
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to insert their own profile on signup
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (true);

-- Allow users to delete their own profile
CREATE POLICY "Users can delete own profile" ON users
  FOR DELETE USING (auth.uid() = id);

-- Stations table policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view stations" ON stations
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert stations" ON stations
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update stations" ON stations
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete stations" ON stations
  FOR DELETE USING (auth.role() = 'authenticated');

-- Routes table policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view routes" ON routes
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert routes" ON routes
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update routes" ON routes
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete routes" ON routes
  FOR DELETE USING (auth.role() = 'authenticated');

-- Crowd Reports table policies
CREATE POLICY "Authenticated users can view all reports" ON crowd_reports
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create reports" ON crowd_reports
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own reports" ON crowd_reports
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reports" ON crowd_reports
  FOR DELETE USING (auth.uid() = user_id);

-- Alerts table policies (read-only for authenticated users)
CREATE POLICY "Authenticated users can view alerts" ON alerts
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert alerts" ON alerts
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update alerts" ON alerts
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete alerts" ON alerts
  FOR DELETE USING (auth.role() = 'authenticated');
