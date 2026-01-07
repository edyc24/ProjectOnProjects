import {create} from 'zustand';
import {User} from '../types/user.types';
import {tokenStorage} from '../services/storage/tokenStorage';
import {authApi} from '../services/api/authApi';

// DEVELOPMENT MODE: Auto-login bypass enabled
// In development, user is automatically logged in as mock user
// Set __DEV__ = false to disable this behavior

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  loginWithToken: (token: string, user: User) => Promise<void>;
  register: (email: string, password: string, firstName: string, lastName: string, phone?: string) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
  setUser: (user: User) => void;
  setToken: (token: string) => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,

  login: async (email: string, password: string) => {
    try {
      set({isLoading: true});
      const response = await authApi.login({email, password});
      await tokenStorage.setToken(response.token);
      set({
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        isLoading: false,
      });
    } catch (error) {
      set({isLoading: false});
      throw error;
    }
  },

  loginWithToken: async (token: string, user: User) => {
    await tokenStorage.setToken(token);
    set({
      user,
      token,
      isAuthenticated: true,
      isLoading: false,
    });
  },

  register: async (email: string, password: string, firstName: string, lastName: string, phone?: string) => {
    try {
      set({isLoading: true});
      const response = await authApi.register({email, password, firstName, lastName, phone});
      await tokenStorage.setToken(response.token);
      set({
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        isLoading: false,
      });
    } catch (error) {
      set({isLoading: false});
      throw error;
    }
  },

  logout: async () => {
    await tokenStorage.removeToken();
    set({
      user: null,
      token: null,
      isAuthenticated: false,
    });
  },

  checkAuth: async () => {
    try {
      // Use real API authentication - no more mock bypass
      const token = await tokenStorage.getToken();
      if (token) {
        const user = await authApi.getCurrentUser();
        set({
          user,
          token,
          isAuthenticated: true,
          isLoading: false,
        });
      } else {
        set({isLoading: false, isAuthenticated: false});
      }
    } catch (error) {
      // If API fails, user is not authenticated
      await tokenStorage.removeToken();
      set({isLoading: false, isAuthenticated: false});
    }
  },

  setUser: (user: User) => {
    set({user});
  },

  setToken: async (token: string) => {
    await tokenStorage.setToken(token);
    set({token});
  },
}));

