-- Create walk_activities table to store individual walk activities
CREATE TABLE IF NOT EXISTS walk_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    owner_id TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    distance_km DOUBLE PRECISION NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT now(),
    route_points JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE walk_activities ENABLE ROW LEVEL SECURITY;

-- Create policy to allow select/insert/update/delete for authenticated owners
CREATE POLICY walk_activities_policy ON walk_activities
    FOR ALL
    TO authenticated
    USING (owner_id = (auth.uid())::text)
    WITH CHECK (owner_id = (auth.uid())::text);
