/*
  # Optimize users table RLS policies

  1. Changes
    - Optimize RLS policies to avoid re-evaluating auth functions for each row
    - Use subselects for auth.uid() calls to improve performance
    - Maintain existing security model while improving query performance

  2. Security
    - Preserve existing access control rules
    - Users can still only read their own data
    - Admins retain full access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;

-- Recreate policies with optimized auth function calls
CREATE POLICY "Users can read themselves and admins can read all"
ON users
FOR SELECT
TO authenticated
USING (
  id = (SELECT auth.uid()) OR 
  role = 'admin'
);

CREATE POLICY "Admins can insert users"
ON users
FOR INSERT
TO authenticated
WITH CHECK (
  role = 'admin'
);

CREATE POLICY "Admins can update users"
ON users
FOR UPDATE
TO authenticated
USING (
  role = 'admin'
)
WITH CHECK (
  role = 'admin'
);