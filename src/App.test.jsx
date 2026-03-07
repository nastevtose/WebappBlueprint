import { render, screen } from '@testing-library/react'
import App from './App'
import { AuthProvider } from './context/AuthContext'

const renderApp = () => render(<AuthProvider><App /></AuthProvider>)

describe('App', () => {
  it('renders login when not authenticated', () => {
    renderApp()
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
  })
})
