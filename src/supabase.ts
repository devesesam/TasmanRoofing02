import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Enable more verbose debug logging in development
const supabaseOptions = { 
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    debug: true // Enable debug logs for auth
  }
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, supabaseOptions);

// Log initialization
console.log('Supabase client initialized with URL:', supabaseUrl);