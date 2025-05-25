/*
  # Optimize RLS policies and fix auth function calls

  1. Changes
    - Replace uid() with auth.uid() for proper function calls
    - Remove duplicate policies
    - Optimize auth function calls using subqueries
    - Update all policies with correct syntax

  2. Security
    - Maintains existing security rules
    - Preserves admin-only access for sensitive operations
    - Keeps read-only access for authenticated users where appropriate
*/

-- Drop duplicate policies for workers table
DROP POLICY IF EXISTS "auth_delete_workers" ON public.workers;
DROP POLICY IF EXISTS "auth_insert_workers" ON public.workers;
DROP POLICY IF EXISTS "auth_select_workers" ON public.workers;
DROP POLICY IF EXISTS "auth_update_workers" ON public.workers;

-- Update workers policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can delete workers" ON public.workers;
CREATE POLICY "Admins can delete workers"
  ON public.workers
  FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Admins can insert workers" ON public.workers;
CREATE POLICY "Admins can insert workers"
  ON public.workers
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Admins can update workers" ON public.workers;
CREATE POLICY "Admins can update workers"
  ON public.workers
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )))
  WITH CHECK ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Anyone can read workers" ON public.workers;
CREATE POLICY "Anyone can read workers"
  ON public.workers
  FOR SELECT
  TO authenticated
  USING (true);

-- Drop duplicate policies for jobs table
DROP POLICY IF EXISTS "auth_delete_jobs" ON public.jobs;
DROP POLICY IF EXISTS "auth_insert_jobs" ON public.jobs;
DROP POLICY IF EXISTS "auth_select_jobs" ON public.jobs;
DROP POLICY IF EXISTS "auth_update_jobs" ON public.jobs;

-- Update jobs policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can delete jobs" ON public.jobs;
CREATE POLICY "Admins can delete jobs"
  ON public.jobs
  FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Admins can insert jobs" ON public.jobs;
CREATE POLICY "Admins can insert jobs"
  ON public.jobs
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Admins can update jobs" ON public.jobs;
CREATE POLICY "Admins can update jobs"
  ON public.jobs
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )))
  WITH CHECK ((SELECT auth.uid() IN (
    SELECT users.id
    FROM users
    WHERE users.role = 'admin'
  )));

DROP POLICY IF EXISTS "Anyone can read jobs" ON public.jobs;
CREATE POLICY "Anyone can read jobs"
  ON public.jobs
  FOR SELECT
  TO authenticated
  USING (true);

-- Update users policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT (auth.jwt() ->> 'role'::text)) = 'admin'::text);

DROP POLICY IF EXISTS "Admins can update users" ON public.users;
CREATE POLICY "Admins can update users"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING ((SELECT (auth.jwt() ->> 'role'::text)) = 'admin'::text)
  WITH CHECK ((SELECT (auth.jwt() ->> 'role'::text)) = 'admin'::text);

DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON public.users;
CREATE POLICY "Users can read themselves and admins can read all"
  ON public.users
  FOR SELECT
  TO authenticated
  USING ((SELECT (auth.jwt() ->> 'role'::text)) = 'admin'::text OR (SELECT auth.uid()) = id);