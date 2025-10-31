-- MetroPulse Database Schema
-- Tables for Bengaluru Metro crowd-sourced transit data

-- Users table (references auth.users)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text,
  phone text,
  notifications_enabled boolean DEFAULT true,
  anonymous_reporting_enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Stations table
CREATE TABLE IF NOT EXISTS stations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL UNIQUE,
  line_color text NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  current_crowd_level text CHECK (current_crowd_level IN ('low', 'moderate', 'high')),
  last_updated timestamptz,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Routes table
CREATE TABLE IF NOT EXISTS routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_station_id uuid NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  to_station_id uuid NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  duration_minutes int NOT NULL,
  fare double precision NOT NULL,
  intermediate_station_ids text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT different_stations CHECK (from_station_id != to_station_id)
);

-- Crowd Reports table
CREATE TABLE IF NOT EXISTS crowd_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  station_id uuid NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  crowd_level text NOT NULL CHECK (crowd_level IN ('low', 'moderate', 'high')),
  timestamp timestamptz DEFAULT now() NOT NULL,
  is_anonymous boolean DEFAULT false,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Alerts table
CREATE TABLE IF NOT EXISTS alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  severity text NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
  affected_station_id uuid REFERENCES stations(id) ON DELETE SET NULL,
  affected_line_color text,
  start_time timestamptz DEFAULT now() NOT NULL,
  end_time timestamptz,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_stations_line_color ON stations(line_color);
CREATE INDEX IF NOT EXISTS idx_stations_code ON stations(code);
CREATE INDEX IF NOT EXISTS idx_routes_from_station ON routes(from_station_id);
CREATE INDEX IF NOT EXISTS idx_routes_to_station ON routes(to_station_id);
CREATE INDEX IF NOT EXISTS idx_crowd_reports_station ON crowd_reports(station_id);
CREATE INDEX IF NOT EXISTS idx_crowd_reports_timestamp ON crowd_reports(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_active ON alerts(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_alerts_station ON alerts(affected_station_id) WHERE is_active = true;
