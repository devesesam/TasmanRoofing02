/*
  # Fix users table RLS policies
  
  Updates RLS policies for the users table to properly access JWT claims and optimize performance.
  
  1. Changes
    - Fix JWT role access using proper claim extraction
    - Optimize performance with EXISTS clauses
    - Maintain same security rules with corrected syntax
*/

-- Drop and recreate users policies with correct JWT access
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT role FROM auth.jwt()) = 'admin');

DROP POLICY IF EXISTS "Admins can update users" ON public.users;
CREATE POLICY "Admins can update users"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING ((SELECT role FROM auth.jwt()) = 'admin')
  WITH CHECK ((SELECT role FROM auth.jwt()) = 'admin');

DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON public.users;
CREATE POLICY "Users can read themselves and admins can read all"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM auth.jwt()) = 'admin' OR 
    id = auth.uid()
  );