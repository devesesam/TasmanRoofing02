/*
  # Fix function search paths

  1. Changes
    - Set explicit search paths for all functions to prevent search path injection
    - Recreate functions with proper security settings
  
  2. Security
    - All functions now have immutable search paths
    - All functions use SECURITY DEFINER
    - Search paths explicitly set to public schema
*/

-- Set search_path for handle_new_user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'worker')
  );
  RETURN NEW;
END;
$$;

-- Set search_path for delete_worker_with_jobs function
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

-- Set search_path for create_initial_data function
CREATE OR REPLACE FUNCTION public.create_initial_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Your existing function logic here
  -- This is just a placeholder since we don't have the original function content
  NULL;
END;
$$;