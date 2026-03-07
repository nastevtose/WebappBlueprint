import { useEffect } from 'react'
import Header from './Header'
import Hero from './Hero'
import Features from './Features'
import Footer from './Footer'
import Login from './Login'
import { useAuth } from './context/AuthContext'

export default function App() {
  const { user, login } = useAuth()

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const token = params.get('token')
    if (token) {
      login(token)
      window.history.replaceState({}, '', window.location.pathname)
    }
  }, [])

  if (!user) return <Login />

  return (
    <>
      <Header />
      <main>
        <Hero />
        <Features />
      </main>
      <Footer />
    </>
  )
}
