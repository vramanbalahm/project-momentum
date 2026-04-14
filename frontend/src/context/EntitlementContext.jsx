// EntitlementContext — manages feature flags for current household
// Loads enabled features from /admin/entitlements on login
import { createContext, useContext, useState } from 'react';
const EntitlementContext = createContext(null);
export const useEntitlements = () => useContext(EntitlementContext);
export default EntitlementContext;
