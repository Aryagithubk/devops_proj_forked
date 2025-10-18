import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [backendData, setBackendData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Get backend URL from environment variable or default
  const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:5000';

  useEffect(() => {
    // Fetch data from backend
    fetch(`${BACKEND_URL}/api/message`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Backend connection failed');
        }
        return response.json();
      })
      .then(data => {
        setBackendData(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [BACKEND_URL]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 DevOps Full Stack Project</h1>
        <div className="card">
          <h2>Frontend (React)</h2>
          <p className="success">✅ React app is running successfully!</p>
        </div>

        <div className="card">
          <h2>Backend Connection</h2>
          {loading && <p className="loading">⏳ Connecting to backend...</p>}
          {error && <p className="error">❌ Error: {error}</p>}
          {backendData && (
            <div className="backend-data">
              <p className="success">✅ Backend connected successfully!</p>
              <div className="data-display">
                <p><strong>Message:</strong> {backendData.message}</p>
                <p><strong>Environment:</strong> {backendData.data?.environment}</p>
                <p><strong>Node Version:</strong> {backendData.data?.node_version}</p>
              </div>
            </div>
          )}
        </div>

        <div className="card">
          <h2>DevOps Tools Used</h2>
          <div className="tools-grid">
            <div className="tool">
              <span className="tool-icon">🏗️</span>
              <span className="tool-name">Terraform</span>
              <span className="tool-desc">Infrastructure</span>
            </div>
            <div className="tool">
              <span className="tool-icon">⚙️</span>
              <span className="tool-name">Ansible</span>
              <span className="tool-desc">Deployment</span>
            </div>
            <div className="tool">
              <span className="tool-icon">🎭</span>
              <span className="tool-name">Puppet</span>
              <span className="tool-desc">Configuration</span>
            </div>
            <div className="tool">
              <span className="tool-icon">📊</span>
              <span className="tool-name">Nagios</span>
              <span className="tool-desc">Monitoring</span>
            </div>
          </div>
        </div>

        <div className="footer">
          <p>🎓 DevOps Learning Project | AWS Free Tier</p>
        </div>
      </header>
    </div>
  );
}

export default App;
