/*
  # Optimize RLS policies for better performance
  
  1. Changes
    - Update RLS policies to use subselects for auth functions
    - Optimize performance by preventing unnecessary re-evaluation
    - Fix policy definitions for workers, jobs, and users tables
  
  2. Security
    - Maintain existing security rules
    - Use proper auth function calls
*/

-- Drop and recreate workers policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can delete workers" ON public.workers;
CREATE POLICY "Admins can delete workers"
  ON public.workers
  FOR DELETE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

DROP POLICY IF EXISTS "Admins can insert workers" ON public.workers;
CREATE POLICY "Admins can insert workers"
  ON public.workers
  FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

DROP POLICY IF EXISTS "Admins can update workers" ON public.workers;
CREATE POLICY "Admins can update workers"
  ON public.workers
  FOR UPDATE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

-- Drop and recreate jobs policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can delete jobs" ON public.jobs;
CREATE POLICY "Admins can delete jobs"
  ON public.jobs
  FOR DELETE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

DROP POLICY IF EXISTS "Admins can insert jobs" ON public.jobs;
CREATE POLICY "Admins can insert jobs"
  ON public.jobs
  FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

DROP POLICY IF EXISTS "Admins can update jobs" ON public.jobs;
CREATE POLICY "Admins can update jobs"
  ON public.jobs
  FOR UPDATE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.users 
    WHERE users.id = (SELECT auth.uid()) 
    AND users.role = 'admin'
  ));

-- Drop and recreate users policies with optimized auth calls
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
CREATE POLICY "Admins can insert users"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.jwt() ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can update users" ON public.users;
CREATE POLICY "Admins can update users"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.jwt() ->> 'role') = 'admin')
  WITH CHECK ((SELECT auth.jwt() ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON public.users;
CREATE POLICY "Users can read themselves and admins can read all"
  ON public.users
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.jwt() ->> 'role') = 'admin' OR id = (SELECT auth.uid()));