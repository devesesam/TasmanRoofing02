/*
  # Fix function search path

  1. Changes
    - Set explicit search_path for delete_worker_with_jobs function
    - Ensure security best practices are followed
    
  2. Security
    - Prevents search_path manipulation
    - Maintains SECURITY DEFINER setting
*/

-- Drop and recreate function with explicit search_path
CREATE OR REPLACE FUNCTION public.delete_worker_with_jobs()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Update jobs to remove worker reference
  UPDATE jobs SET worker_id = NULL WHERE worker_id = OLD.id;
  
  -- Delete secondary worker assignments
  DELETE FROM job_secondary_workers WHERE worker_id = OLD.id;
  
  RETURN OLD;
END;
$$;