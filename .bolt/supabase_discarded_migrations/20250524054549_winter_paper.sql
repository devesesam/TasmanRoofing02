/*
  # Fix function search paths

  1. Changes
     - Sets explicit search_path for functions to improve security
     - Applies to three functions: handle_new_user, delete_worker_with_jobs, and create_initial_data
     - Addresses "Function Search Path Mutable" security warnings
  
  2. Security
     - Prevents potential SQL injection attacks
     - Ensures functions only use objects from the public schema
*/

-- First, handle the handle_new_user function
DO $$
DECLARE
  func_body text;
BEGIN
  SELECT pg_get_functiondef(oid) INTO func_body
  FROM pg_proc
  WHERE proname = 'handle_new_user'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Extract the function body (everything between dollar-quoted strings)
    func_body := substring(func_body FROM '\$\$(.+?)\$\$' FOR '$1');
    
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
BEGIN
  SELECT pg_get_functiondef(oid) INTO func_body
  FROM pg_proc
  WHERE proname = 'delete_worker_with_jobs'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Extract the function body
    func_body := substring(func_body FROM '\$\$(.+?)\$\$' FOR '$1');
    
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
BEGIN
  SELECT pg_get_functiondef(oid) INTO func_body
  FROM pg_proc
  WHERE proname = 'create_initial_data'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  -- Only proceed if the function exists
  IF FOUND THEN
    -- Extract the function body
    func_body := substring(func_body FROM '\$\$(.+?)\$\$' FOR '$1');
    
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