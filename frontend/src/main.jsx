import './index.css'
import { StrictMode, useState } from 'react'
import { createRoot } from 'react-dom/client'
import { AuthProvider } from './context/AuthContext'
import { useAuth } from './context/AuthContext'
import App from './App.jsx'
import Login from './pages/Login.jsx'
import Register from './pages/Register.jsx'

// AuthGate — isolated from App's state so Login/Register inputs never lose focus
function AuthGate() {
  const { isAuthenticated, loading: authLoading } = useAuth();
  const [authScreen, setAuthScreen] = useState('login');

  if (authLoading) {
    return (
      <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ color: "#9FE1CB", fontSize: 14 }}>Loading...</div>
      </div>
    );
  }

  if (!isAuthenticated) {
    if (authScreen === 'register') {
      return <Register onSwitchToLogin={() => setAuthScreen('login')} />;
    }
    return <Login onSwitchToRegister={() => setAuthScreen('register')} />;
  }

  return <App />;
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <AuthProvider>
      <AuthGate />
    </AuthProvider>
  </StrictMode>,
)
