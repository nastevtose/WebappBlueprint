import { useAuth } from './context/AuthContext'

export default function Header() {
  const { user, logout } = useAuth()

  return (
    <header>
      <div className="logo">Yalitz Blueprint</div>
      <nav aria-label="Main navigation">
        <a href="#">Home</a>
        <a href="#">About</a>
        <a href="#">Contact</a>
      </nav>
      {user && (
        <div className="user-menu">
          <span className="user-name">{user.name}</span>
          <button className="btn-logout" onClick={logout}>Sign out</button>
        </div>
      )}
    </header>
  )
}
