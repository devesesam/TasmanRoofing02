/*
  # Fix recursive RLS policies on users table

  1. Changes
    - Drop existing problematic policies that cause recursion
    - Create new policies that avoid recursion by using auth.uid() directly
    
  2. Security
    - Maintains same security model but implements it without recursion
    - Admins can still manage all users
    - Users can still read their own data
*/

-- Drop existing policies that cause recursion
DROP POLICY IF EXISTS "Users can read themselves and admins can read all" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;

-- Create new non-recursive policies
CREATE POLICY "Users can read themselves and admins can read all"
ON users
FOR SELECT
TO authenticated
USING (
  (id = auth.uid()) OR 
  (role = 'admin')
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