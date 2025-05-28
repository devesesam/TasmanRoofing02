/*
  # Optimize users table RLS policies
  
  1. Changes
    - Optimize RLS policies for the users table to prevent unnecessary re-evaluation
    - Wrap auth function calls in subselects for better performance
    - Maintain existing security rules while improving query efficiency
*/

-- Drop and recreate users policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1
    FROM auth.jwt() j
    WHERE j.role = 'admin'
  ));

DROP POLICY IF EXISTS "Admins can update users" ON public.users;
CREATE POLICY "Admins can update users"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (EXISTS (
    SELECT 1
    FROM auth.jwt() j
    WHERE j.role = 'admin'
  ))
  WITH CHECK (EXISTS (
    SELECT 1
    FROM auth.jwt() j
    WHERE j.role = 'admin'
  ));

DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON public.users;
CREATE POLICY "Users can read themselves and admins can read all"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM auth.jwt() j
      WHERE j.role = 'admin'
    ) OR 
    id = (SELECT auth.uid())
  );