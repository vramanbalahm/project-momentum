// AuthContext — manages logged-in user and household_id
// Replaces hardcoded ACTIVE_H_ID once auth is built
import { createContext, useContext, useState } from 'react';
const AuthContext = createContext(null);
export const useAuth = () => useContext(AuthContext);
export default AuthContext;
