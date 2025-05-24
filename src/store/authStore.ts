import { create } from 'zustand';
import { supabase } from '../supabase';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'worker';
}

interface AuthState {
  user: User | null;
  loading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
  signup: (name: string, email: string, password: string) => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  loading: true,
  error: null,

  checkAuth: async () => {
    try {
      set({ loading: true });
      const { data: { session } } = await supabase.auth.getSession();
      
      if (session?.user) {
        // Fetch the user data from the users table
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('id', session.user.id)
          .maybeSingle(); // Changed from single() to maybeSingle()
          
        if (userError) {
          throw userError;
        }
        
        if (!userData) {
          // No user found with this ID in the users table
          console.warn(`No user record found in 'users' table for authenticated user ID: ${session.user.id}`);
          set({ user: null, loading: false });
          // Optionally sign out the user since their account setup is incomplete
          await supabase.auth.signOut();
          return;
        }
        
        set({ 
          user: userData,
          loading: false 
        });
      } else {
        set({ user: null, loading: false });
      }
    } catch (error) {
      set({ user: null, loading: false, error: (error as Error).message });
    }
  },

  login: async (email, password) => {
    try {
      set({ loading: true, error: null });
      
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      
      if (error) {
        throw error;
      }
      
      if (data.user) {
        // Fetch the user data from the users table
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('id', data.user.id)
          .maybeSingle(); // Changed from single() to maybeSingle()
          
        if (userError) {
          throw userError;
        }
        
        if (!userData) {
          // No user found with this ID in the users table
          console.warn(`No user record found in 'users' table for authenticated user ID: ${data.user.id}`);
          set({ 
            user: null, 
            loading: false,
            error: "User account not found. Please contact an administrator."
          });
          // Sign out the user since their account setup is incomplete
          await supabase.auth.signOut();
          return;
        }
        
        set({ 
          user: userData,
          loading: false 
        });
      }
    } catch (error) {
      set({ loading: false, error: (error as Error).message });
    }
  },

  signup: async (name, email, password) => {
    try {
      set({ loading: true, error: null });
      
      // 1. Create auth user
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      });
      
      if (error) throw error;
      if (!data.user) throw new Error('Signup failed - no user returned');
      
      // 2. Create user record in the users table
      // Default to worker role for self-signup
      const { error: insertError } = await supabase
        .from('users')
        .insert({
          id: data.user.id,
          name,
          email,
          role: 'worker' // Default role for new signups
        });
      
      if (insertError) {
        // Rollback by deleting the auth user if possible
        console.error('Failed to create user record:', insertError);
        throw insertError;
      }
      
      set({ 
        loading: false,
        error: 'Signup successful! Please wait for admin approval before logging in.'
      });
      
      // Sign out after successful signup to require admin approval
      await supabase.auth.signOut();
      
    } catch (error) {
      set({ loading: false, error: (error as Error).message });
    }
  },

  logout: async () => {
    try {
      set({ loading: true });
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        throw error;
      }
      
      set({ user: null, loading: false });
    } catch (error) {
      set({ loading: false, error: (error as Error).message });
    }
  },
}));