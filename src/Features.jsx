const FEATURES = [
  { icon: '⚡', title: 'Fast Setup', desc: 'Zero config to get running. Clone, build, and go.' },
  { icon: '🔒', title: 'Secure', desc: 'Built with security best practices from the ground up.' },
  { icon: '⚙️', title: 'CI/CD Ready', desc: 'GitHub Actions pipeline included and ready to use.' },
  { icon: '🚀', title: 'Scalable', desc: 'Designed to grow with your project from day one.' },
]

export default function Features() {
  return (
    <section className="features">
      {FEATURES.map(f => (
        <div key={f.title} className="card">
          <div className="icon">{f.icon}</div>
          <h3>{f.title}</h3>
          <p>{f.desc}</p>
        </div>
      ))}
    </section>
  )
}
