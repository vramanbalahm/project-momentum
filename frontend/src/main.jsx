import './index.css'
import { StrictMode, useState } from 'react'
import { createRoot } from 'react-dom/client'
import { AuthProvider } from './context/AuthContext'
import { useAuth } from './context/AuthContext'
import App from './App.jsx'
import Login from './pages/Login.jsx'
import Register from './pages/Register.jsx'
import Dashboard from './pages/Dashboard.jsx'
import FamilyProfile from './pages/FamilyProfile.jsx'
import ManageMembers from './pages/ManageMembers.jsx'
import OnboardingWizard from './pages/OnboardingWizard.jsx'
import MyProfile from './pages/MyProfile.jsx'
import MemberAvailability from './pages/MemberAvailability.jsx'
import RecipeReview from './pages/RecipeReview.jsx'
import HelpScreen from './pages/HelpScreen.jsx'
import HouseholdSettings from './pages/HouseholdSettings.jsx'
import ReviewerProgress from './pages/ReviewerProgress.jsx'

// AuthGate — isolated from App's state so Login/Register inputs never lose focus
function AuthGate() {
  const { isAuthenticated, loading: authLoading, user } = useAuth();
  const [authScreen, setAuthScreen] = useState('login');
  const [screen, setScreen] = useState('dashboard');
  const [reviewerNavParams, setReviewerNavParams] = useState({}); // dashboard | weekly_plan | family_profile | manage_members | member_availability | recipe_review
  const [helpReturnRecipeId, setHelpReturnRecipeId] = useState(null);

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

  // Authenticated — always reset authScreen to login so logout never lands on register
  if (authScreen !== 'login') setAuthScreen('login');

  // Authenticated — show onboarding wizard if not yet completed
  if (!user?.onboarding_done) return <OnboardingWizard onComplete={() => window.location.reload()} />;

  // Authenticated — route to correct screen
  if (screen === 'weekly_plan') return <App onBack={() => setScreen('dashboard')} />;
  if (screen === 'family_profile') return <FamilyProfile onBack={() => setScreen('dashboard')} />;
  if (screen === 'my_profile') return <MyProfile onBack={() => setScreen('dashboard')} />;
  if (screen === 'manage_members') return <ManageMembers onBack={() => setScreen('dashboard')} />;
  if (screen === 'recipe_review') return (
    <RecipeReview onBack={() => { setReviewerNavParams({}); setScreen('dashboard'); }} onHelp={(recipeId) => { setHelpReturnRecipeId(recipeId); setScreen('help'); }} helpReturnRecipeId={helpReturnRecipeId} initialTab={reviewerNavParams.initialTab || 'under_review'} filterReviewerId={reviewerNavParams.filterReviewerId || null} />
  );
  if (screen === 'help') return (
    <HelpScreen onBack={() => { setScreen('recipe_review'); }} returnRecipeId={helpReturnRecipeId} />
  );
  if (screen === 'household_settings') return <HouseholdSettings onBack={() => setScreen('dashboard')} />;
  if (screen === 'reviewer_progress') return <ReviewerProgress onBack={() => setScreen('dashboard')} onNavigate={(params) => { setReviewerNavParams(params); setScreen('recipe_review'); }} />;
  if (screen === 'member_availability') return (
    <MemberAvailability
      onBack={() => setScreen('dashboard')}
      onProceed={() => setScreen('weekly_plan')}
    />
  );

  return <Dashboard onNavigate={setScreen} />;
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <AuthProvider>
      <AuthGate />
    </AuthProvider>
  </StrictMode>,
)
