import { createContext, useContext, useState, useEffect, useCallback } from "react";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";
const AuthContext = createContext(null);

async function apiFetch(path, options = {}, { skipLogoutOn401 = false } = {}) {
  const token = localStorage.getItem("access_token");
  const res = await fetch(`${API_BASE}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    ...options
  });
  if (res.status === 401) {
    if (!skipLogoutOn401) {
      window.dispatchEvent(new Event("auth:logout"));
      throw new Error("Your session has expired. Please log in again.");
    }
    // For login/register — surface the backend error message directly
    const err = await res.json().catch(() => ({ detail: "Invalid email or password." }));
    throw new Error(err.detail || "Invalid email or password.");
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({ detail: "Request failed" }));
    throw new Error(err.detail || "Request failed");
  }
  if (res.status === 204) return null;
  return res.json();
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const storeTokens = (access_token, refresh_token) => {
    localStorage.setItem("access_token", access_token);
    if (refresh_token) localStorage.setItem("refresh_token", refresh_token);
  };

  const clearTokens = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
  };

  useEffect(() => {
    const bootstrap = async () => {
      const token = localStorage.getItem("access_token");
      if (!token) { setLoading(false); return; }
      try {
        const me = await apiFetch("/auth/me");
        setUser(me);
      } catch {
        clearTokens();
      } finally {
        setLoading(false);
      }
    };
    bootstrap();
  }, []);

  useEffect(() => {
    const handler = () => { clearTokens(); setUser(null); };
    window.addEventListener("auth:logout", handler);
    return () => window.removeEventListener("auth:logout", handler);
  }, []);

  const login = useCallback(async (email, password) => {
    clearTokens(); setUser(null);
    const data = await apiFetch("/auth/login", {
      method: "POST", body: JSON.stringify({ email, password })
    }, { skipLogoutOn401: true });
    storeTokens(data.access_token, data.refresh_token);
    const me = await apiFetch("/auth/me");
    setUser(me);
    return me;
  }, []);

  const register = useCallback(async (payload) => {
    const data = await apiFetch("/auth/register", {
      method: "POST", body: JSON.stringify(payload)
    }, { skipLogoutOn401: true });
    storeTokens(data.access_token, data.refresh_token);
    const me = await apiFetch("/auth/me");
    setUser(me);
    return me;
  }, []);

  const logout = useCallback(async () => {
    try {
      const refresh_token = localStorage.getItem("refresh_token");
      if (refresh_token) await apiFetch("/auth/logout", {
        method: "POST", body: JSON.stringify({ refresh_token })
      });
    } catch { }
    finally { clearTokens(); setUser(null); }
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, isAuthenticated: Boolean(user), login, register, logout, apiFetch }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within <AuthProvider>");
  return ctx;
};
