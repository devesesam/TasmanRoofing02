/*
  # Fix function search paths for security

  1. Changes
     - Updates all database functions to explicitly set search_path to public
     - Addresses "Function Search Path Mutable" security warnings
     
  2. Security Benefits
     - Prevents potential search_path manipulation attacks
     - Ensures functions always use expected schema objects
     - Follows security best practices recommended by Supabase
*/

-- Handle the handle_new_user function
DO $$
DECLARE
  func_body text;
  func_text text;
  start_pos int;
  end_pos int;
BEGIN
  -- Get the function definition
  SELECT pg_get_functiondef(oid) INTO func_text
  FROM pg_proc
  WHERE proname = 'handle_new_user'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Find the positions of the body delimiters
    start_pos := position('$$' in func_text) + 2;
    end_pos := position('$$;' in func_text) - 1;
    
    -- Extract the function body
    func_body := substring(func_text from start_pos for (end_pos - start_pos + 1));
    
    -- Drop the existing function
    EXECUTE 'DROP FUNCTION IF EXISTS public.handle_new_user();';
    
    -- Recreate the function with explicit search_path
    EXECUTE 'CREATE OR REPLACE FUNCTION public.handle_new_user() 
      RETURNS trigger 
      LANGUAGE plpgsql 
      SECURITY DEFINER
      SET search_path = public
    AS $func$
    ' || func_body || '
    $func$;';
  END IF;
END
$$;

-- Fix delete_worker_with_jobs function
DO $$
DECLARE
  func_body text;
  func_text text;
  start_pos int;
  end_pos int;
BEGIN
  -- Get the function definition
  SELECT pg_get_functiondef(oid) INTO func_text
  FROM pg_proc
  WHERE proname = 'delete_worker_with_jobs'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Find the positions of the body delimiters
    start_pos := position('$$' in func_text) + 2;
    end_pos := position('$$;' in func_text) - 1;
    
    -- Extract the function body
    func_body := substring(func_text from start_pos for (end_pos - start_pos + 1));
    
    -- Drop the existing function (using the correct signature)
    EXECUTE 'DROP FUNCTION IF EXISTS public.delete_worker_with_jobs(worker_id uuid);';
    
    -- Recreate with explicit search_path
    EXECUTE 'CREATE OR REPLACE FUNCTION public.delete_worker_with_jobs(worker_id uuid) 
      RETURNS void 
      LANGUAGE plpgsql 
      SECURITY DEFINER
      SET search_path = public
    AS $func$
    ' || func_body || '
    $func$;';
  END IF;
END
$$;

-- Fix create_initial_data function
DO $$
DECLARE
  func_body text;
  func_text text;
  start_pos int;
  end_pos int;
BEGIN
  -- Get the function definition
  SELECT pg_get_functiondef(oid) INTO func_text
  FROM pg_proc
  WHERE proname = 'create_initial_data'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Find the positions of the body delimiters
    start_pos := position('$$' in func_text) + 2;
    end_pos := position('$$;' in func_text) - 1;
    
    -- Extract the function body
    func_body := substring(func_text from start_pos for (end_pos - start_pos + 1));
    
    -- Drop the existing function
    EXECUTE 'DROP FUNCTION IF EXISTS public.create_initial_data();';
    
    -- Recreate with explicit search_path
    EXECUTE 'CREATE OR REPLACE FUNCTION public.create_initial_data() 
      RETURNS void 
      LANGUAGE plpgsql 
      SECURITY DEFINER
      SET search_path = public
    AS $func$
    ' || func_body || '
    $func$;';
  END IF;
END
$$;