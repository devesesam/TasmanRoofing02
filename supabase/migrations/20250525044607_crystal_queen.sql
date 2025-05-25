/*
  # Fix users table RLS policies

  1. Changes
    - Optimize RLS policies to prevent unnecessary re-evaluation
    - Fix JWT claim access syntax
    - Maintain existing security rules

  2. Security
    - Preserve admin-only insert/update restrictions
    - Keep user read access to own data
    - Allow admin read access to all records
*/

-- Drop and recreate users policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT users.role FROM users WHERE users.id = auth.uid()) = 'admin');

DROP POLICY IF EXISTS "Admins can update users" ON public.users;
CREATE POLICY "Admins can update users"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING ((SELECT users.role FROM users WHERE users.id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT users.role FROM users WHERE users.id = auth.uid()) = 'admin');

DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON public.users;
CREATE POLICY "Users can read themselves and admins can read all"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    (SELECT users.role FROM users WHERE users.id = auth.uid()) = 'admin' OR 
    id = (SELECT auth.uid())
  );