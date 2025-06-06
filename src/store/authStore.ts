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
      
      console.log('Session check:', session ? 'Session exists' : 'No session');
      
      if (session?.user) {
        console.log('Auth user found:', { 
          id: session.user.id, 
          email: session.user.email 
        });
        
        // Fetch the user data from the users table
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('id', session.user.id)
          .maybeSingle();
          
        if (userError) {
          console.error('Error fetching user data:', userError);
          throw userError;
        }
        
        console.log('User data from users table:', userData);
        
        if (!userData) {
          // No user found with this ID in the users table
          console.warn(`No user record found in 'users' table for authenticated user ID: ${session.user.id}`);
          
          // Check if the email exists in the users table with a different ID
          const { data: emailCheck } = await supabase
            .from('users')
            .select('id, email, name, role')
            .eq('email', session.user.email)
            .maybeSingle();
            
          if (emailCheck) {
            console.warn(`Found user with same email but different ID: ${JSON.stringify(emailCheck)}`);
          }
          
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
      console.error('Auth check error:', error);
      set({ user: null, loading: false, error: (error as Error).message });
    }
  },

  login: async (email, password) => {
    try {
      set({ loading: true, error: null });
      console.log('Attempting login with email:', email);
      
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      
      if (error) {
        console.error('Login error from Supabase Auth:', error);
        throw error;
      }
      
      console.log('Auth login successful, user ID:', data.user?.id);
      
      if (data.user) {
        // Fetch the user data from the users table
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('id', data.user.id)
          .maybeSingle();
          
        if (userError) {
          console.error('Error fetching user data after login:', userError);
          throw userError;
        }
        
        console.log('User data from users table after login:', userData);
        
        if (!userData) {
          // No user found with this ID in the users table
          console.warn(`No user record found in 'users' table for authenticated user ID: ${data.user.id}`);
          
          // Check if the user exists with a different ID
          const { data: emailCheck } = await supabase
            .from('users')
            .select('id, email, name, role')
            .eq('email', email)
            .maybeSingle();
            
          console.log('Email check in users table:', emailCheck);
          
          if (emailCheck) {
            console.warn(`Found user with same email but different ID in users table:`, emailCheck);
          }
          
          // Instead of trying to create a user record (which violates RLS),
          // just inform the user their account setup is incomplete
          set({ 
            user: null, 
            loading: false,
            error: "User account not found or incomplete. Please contact an administrator to complete your account setup."
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
      console.error('Login process error:', error);
      set({ loading: false, error: (error as Error).message });
    }
  },

  signup: async (name, email, password) => {
    try {
      set({ loading: true, error: null });
      console.log('Attempting signup with email:', email);
      
      // 1. Create auth user
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      });
      
      if (error) {
        console.error('Signup error from Supabase Auth:', error);
        throw error;
      }
      
      if (!data.user) throw new Error('Signup failed - no user returned');
      
      console.log('Auth signup successful, user ID:', data.user.id);
      
      // Due to RLS, we can't create the user record here
      // Instead, inform the user they need admin approval
      set({ 
        loading: false,
        error: 'Signup successful! Please contact an administrator to complete your account setup before logging in.'
      });
      
      // Sign out after successful signup to require admin approval
      await supabase.auth.signOut();
      
    } catch (error) {
      console.error('Signup process error:', error);
      set({ loading: false, error: (error as Error).message });
    }
  },

  logout: async () => {
    try {
      set({ loading: true });
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        console.error('Logout error:', error);
        throw error;
      }
      
      set({ user: null, loading: false });
    } catch (error) {
      console.error('Logout process error:', error);
      set({ loading: false, error: (error as Error).message });
    }
  },
}));