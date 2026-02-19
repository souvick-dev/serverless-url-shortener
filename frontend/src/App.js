import React, { useState, useEffect } from 'react';

const API_URL = 'https://bue01v6k2e.execute-api.us-east-1.amazonaws.com/dev';

function App() {
  const [originalUrl, setOriginalUrl] = useState('');
  const [urls, setUrls] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchUrls();
  }, []);

  const fetchUrls = async () => {
    try {
      const response = await fetch(`${API_URL}/urls?userId=demo-user`);
      const data = await response.json();
      setUrls(data.urls || []);
    } catch (error) {
      console.error('Error fetching URLs:', error);
    }
  };

  const createShortUrl = async () => {
    if (!originalUrl) return;
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/urls`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ originalUrl, userId: 'demo-user' })
      });
      const data = await response.json();
      setMessage(`Short URL created: ${API_URL}/urls/${data.shortCode}`);
      setOriginalUrl('');
      fetchUrls();
    } catch (error) {
      setMessage('Error creating URL');
    }
    setLoading(false);
  };

  const deleteUrl = async (shortCode) => {
    try {
      await fetch(`${API_URL}/urls/${shortCode}`, { method: 'DELETE' });
      fetchUrls();
    } catch (error) {
      console.error('Error deleting URL:', error);
    }
  };

  return (
    <div style={{ maxWidth: '800px', margin: '40px auto', padding: '20px', fontFamily: 'Arial' }}>
      <h1 style={{ color: '#232f3e', textAlign: 'center' }}>🔗 URL Shortener</h1>
      <p style={{ textAlign: 'center', color: '#666' }}>Powered by AWS Lambda + DynamoDB</p>

      <div style={{ background: '#f5f5f5', padding: '20px', borderRadius: '8px', marginBottom: '20px' }}>
        <input
          type="text"
          value={originalUrl}
          onChange={(e) => setOriginalUrl(e.target.value)}
          placeholder="Paste your long URL here..."
          style={{ width: '70%', padding: '10px', fontSize: '16px', borderRadius: '4px', border: '1px solid #ccc' }}
        />
        <button
          onClick={createShortUrl}
          disabled={loading}
          style={{ marginLeft: '10px', padding: '10px 20px', background: '#ff9900', color: 'white', border: 'none', borderRadius: '4px', fontSize: '16px', cursor: 'pointer' }}
        >
          {loading ? 'Creating...' : 'Shorten!'}
        </button>
      </div>

      {message && <div style={{ background: '#d4edda', padding: '10px', borderRadius: '4px', marginBottom: '20px', color: '#155724' }}>{message}</div>}

      <h2>Your Shortened URLs</h2>
      {urls.length === 0 ? (
        <p style={{ color: '#666' }}>No URLs yet. Create your first one above!</p>
      ) : (
        urls.map((url) => (
          <div key={url.shortCode} style={{ background: 'white', border: '1px solid #ddd', padding: '15px', borderRadius: '8px', marginBottom: '10px' }}>
            <p><strong>Short Code:</strong> {url.shortCode}</p>
            <p><strong>Original:</strong> <a href={url.originalUrl} target="_blank" rel="noreferrer">{url.originalUrl}</a></p>
            <p><strong>Clicks:</strong> {url.clickCount || 0}</p>
            <button onClick={() => deleteUrl(url.shortCode)} style={{ background: '#dc3545', color: 'white', border: 'none', padding: '5px 15px', borderRadius: '4px', cursor: 'pointer' }}>Delete</button>
          </div>
        ))
      )}
    </div>
  );
}

export default App;