import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('renders hero heading', () => {
    render(<App />)
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
  })

  it('renders all feature cards', () => {
    render(<App />)
    expect(screen.getByText('Fast Setup')).toBeInTheDocument()
    expect(screen.getByText('Secure')).toBeInTheDocument()
    expect(screen.getByText('CI/CD Ready')).toBeInTheDocument()
    expect(screen.getByText('Scalable')).toBeInTheDocument()
  })

  it('renders navigation links', () => {
    render(<App />)
    const nav = screen.getByRole('navigation', { name: 'Main navigation' })
    expect(nav).toBeInTheDocument()
    expect(nav).toHaveTextContent('Home')
    expect(nav).toHaveTextContent('About')
    expect(nav).toHaveTextContent('Contact')
  })
})
