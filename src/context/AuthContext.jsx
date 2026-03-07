import { createContext, useContext, useState } from 'react'

const AuthContext = createContext(null)

function parseToken(token) {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    if (payload.exp * 1000 < Date.now()) return null
    return { email: payload.sub, name: payload.name }
  } catch {
    return null
  }
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const token = localStorage.getItem('token')
    return token ? parseToken(token) : null
  })

  function login(token) {
    localStorage.setItem('token', token)
    setUser(parseToken(token))
  }

  function logout() {
    localStorage.removeItem('token')
    setUser(null)
  }

  function getToken() {
    return localStorage.getItem('token')
  }

  return (
    <AuthContext.Provider value={{ user, login, logout, getToken }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
