-- =====================================================================
-- PawPing Supabase Storage Configuration Script
-- =====================================================================
-- Run this script in the Supabase SQL Editor to configure the
-- 'pet-avatars' bucket and its Row Level Security (RLS) policies.
-- =====================================================================

-- 1. Create the public 'pet-avatars' bucket if it does not already exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-avatars', 'pet-avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Drop existing policies on storage.objects for 'pet-avatars' if any to prevent collision errors
DROP POLICY IF EXISTS "Allow public read access for pet-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated upload for pet-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated update for pet-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated delete for pet-avatars" ON storage.objects;

-- 3. Policy to allow public read/select access to all files in 'pet-avatars'
CREATE POLICY "Allow public read access for pet-avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'pet-avatars');

-- 4. Policy to allow authenticated users to upload/insert new files to 'pet-avatars'
CREATE POLICY "Allow authenticated upload for pet-avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'pet-avatars');

-- 5. Policy to allow authenticated users to update their files in 'pet-avatars'
CREATE POLICY "Allow authenticated update for pet-avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'pet-avatars');

-- 6. Policy to allow authenticated users to delete their files in 'pet-avatars'
CREATE POLICY "Allow authenticated delete for pet-avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'pet-avatars');
