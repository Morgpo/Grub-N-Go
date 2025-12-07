/**
 * AuthContext - Authentication State Management
 * 
 * DESIGN DECISION: This context is intentionally unchanged for customer-only frontend.
 * 
 * The AuthContext continues to support role-based authentication state (userId, userRole, userEmail)
 * even though the active frontend only supports customer accounts. This design maintains future
 * extensibility, allowing restaurant functionality to be easily restored by uncommenting the
 * relevant UI components without requiring changes to the authentication layer.
 * 
 * Key features preserved:
 * - Role-based state management (userRole stored in localStorage)
 * - Generic user object structure that works for any role
 * - Logout functionality that clears all authentication data
 * - Authentication status checking
 * 
 * Requirements: 4.4 - Backend and database remain unchanged, authentication layer supports all roles
 */
import { createContext, useContext, useState, useEffect } from "react";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in on mount
    const userId = localStorage.getItem("userId");
    const userRole = localStorage.getItem("userRole");
    const userEmail = localStorage.getItem("userEmail");

    if (userId && userRole && userEmail) {
      setUser({
        id: parseInt(userId),
        role: userRole,
        email: userEmail,
      });
    }
    setLoading(false);
  }, []);

  const logout = () => {
    localStorage.removeItem("userId");
    localStorage.removeItem("userRole");
    localStorage.removeItem("userEmail");
    setUser(null);
  };

  const value = {
    user,
    setUser,
    logout,
    loading,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
