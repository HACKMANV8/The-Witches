-- Users table definition
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT,
    phone TEXT,
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    anonymous_reporting_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_email_unique UNIQUE (email)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_users_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at_column();

-- Define RLS policies
-- Users can read their own data
CREATE POLICY users_select_own ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own data, but not their id or email
CREATE POLICY users_update_own ON public.users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id AND
        id = OLD.id AND 
        email = OLD.email
    );

-- Service roles can create users
CREATE POLICY users_insert_service ON public.users
    FOR INSERT
    WITH CHECK (true);

-- Service roles can delete users
CREATE POLICY users_delete_service ON public.users
    FOR DELETE
    USING (true);