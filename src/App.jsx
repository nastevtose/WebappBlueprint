export default function App() {
  return (
    <>
      <header>
        <div className="logo">WebappBlueprint</div>
        <nav>
          <a href="#">Home</a>
          <a href="#">About</a>
          <a href="#">Contact</a>
        </nav>
      </header>

      <section className="hero">
        <h1>Build faster,<br /><span>ship smarter</span></h1>
        <p>A minimal blueprint for modern web applications. Clean structure, ready to extend, and built for real-world use.</p>
        <div className="cta">
          <a href="#" className="btn btn-primary">Get Started</a>
          <a href="#" className="btn btn-secondary">Learn More</a>
        </div>
      </section>

      <section className="features">
        <div className="card">
          <div className="icon">⚡</div>
          <h3>Fast Setup</h3>
          <p>Zero config to get running. Clone, build, and go.</p>
        </div>
        <div className="card">
          <div className="icon">🔒</div>
          <h3>Secure</h3>
          <p>Built with security best practices from the ground up.</p>
        </div>
        <div className="card">
          <div className="icon">⚙️</div>
          <h3>CI/CD Ready</h3>
          <p>GitHub Actions pipeline included and ready to use.</p>
        </div>
        <div className="card">
          <div className="icon">🚀</div>
          <h3>Scalable</h3>
          <p>Designed to grow with your project from day one.</p>
        </div>
      </section>

      <footer>
        &copy; 2026 WebappBlueprint. All rights reserved.
      </footer>
    </>
  )
}
