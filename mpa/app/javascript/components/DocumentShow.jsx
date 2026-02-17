import React, { useState, useEffect } from 'react';

const DocumentShow = ({ documentId }) => {
  const [document, setDocument] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchDocument();
  }, [documentId]);

  const fetchDocument = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/documents/${documentId}`);
      const data = await response.json();

      if (data.success) {
        setDocument(data.document);
        setError(null);
      } else {
        setError(data.error || 'Failed to load document');
      }
    } catch (err) {
      setError('Network error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      uploaded: '#2196F3',
      reviewed: '#FF9800',
      signed: '#4CAF50',
      archived: '#F44336'
    };
    return colors[status] || '#999';
  };

  const getStatusIcon = (status) => {
    const icons = {
      uploaded: '📤',
      reviewed: '👁️',
      signed: '✅',
      archived: '📦'
    };
    return icons[status] || '📄';
  };

  if (loading) {
    return (
      <div className="document-show">
        <div className="loading-container">
          <div className="spinner"></div>
          <p>Loading document...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="document-show">
        <div className="error-container">
          <div className="error-icon">⚠️</div>
          <h2>Error</h2>
          <p>{error}</p>
          <button onClick={() => window.history.back()} className="back-button">
            ← Go Back
          </button>
        </div>
      </div>
    );
  }

  if (!document) {
    return (
      <div className="document-show">
        <div className="not-found">
          <div className="not-found-icon">🔍</div>
          <h2>Document Not Found</h2>
          <p>The document you're looking for doesn't exist.</p>
          <button onClick={() => window.history.back()} className="back-button">
            ← Go Back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="document-show">
      <div className="document-container">
        {/* Header */}
        <div className="document-header">
          <button onClick={() => window.history.back()} className="back-button">
            ← Back to Search
          </button>
          
          <div className="document-meta">
            <span className="document-id">ID: {document.id}</span>
            {document.score && (
              <span className="document-score">
                ⭐ Relevance: {document.score.toFixed(2)}
              </span>
            )}
          </div>
        </div>

        {/* Title */}
        <div className="document-title-section">
          <h1 className="document-title">{document.title}</h1>
          <div 
            className="document-status-badge"
            style={{ backgroundColor: getStatusColor(document.status) }}
          >
            {getStatusIcon(document.status)} {document.status?.toUpperCase() || 'UNKNOWN'}
          </div>
        </div>

        {/* Content */}
        <div className="document-content-section">
          <h2>📄 Content</h2>
          <div className="document-content">
            {document.content}
          </div>
        </div>

        {/* Actions */}
        <div className="document-actions">
          <button className="action-button primary" onClick={() => alert('Download feature coming soon!')}>
            ⬇️ Download
          </button>
          <button className="action-button secondary" onClick={() => alert('Share feature coming soon!')}>
            🔗 Share
          </button>
          <button className="action-button secondary" onClick={() => alert('Edit feature coming soon!')}>
            ✏️ Edit
          </button>
        </div>
      </div>

      <style>{`
        .document-show {
          max-width: 900px;
          margin: 0 auto;
          padding: 40px 20px;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        }

        .document-container {
          background: white;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.1);
          overflow: hidden;
        }

        .document-header {
          padding: 20px 30px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .back-button {
          background: rgba(255,255,255,0.2);
          color: white;
          border: none;
          padding: 10px 20px;
          border-radius: 8px;
          cursor: pointer;
          font-size: 14px;
          font-weight: 600;
          transition: background 0.3s;
        }

        .back-button:hover {
          background: rgba(255,255,255,0.3);
        }

        .document-meta {
          display: flex;
          gap: 15px;
          font-size: 13px;
        }

        .document-id, .document-score {
          background: rgba(255,255,255,0.2);
          padding: 6px 12px;
          border-radius: 6px;
        }

        .document-title-section {
          padding: 40px 30px 30px;
          border-bottom: 2px solid #f0f0f0;
          display: flex;
          justify-content: space-between;
          align-items: start;
          gap: 20px;
        }

        .document-title {
          font-size: 2.5rem;
          margin: 0;
          color: #2c3e50;
          line-height: 1.2;
          flex: 1;
        }

        .document-status-badge {
          padding: 10px 20px;
          border-radius: 20px;
          color: white;
          font-weight: bold;
          font-size: 14px;
          white-space: nowrap;
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .document-content-section {
          padding: 40px 30px;
        }

        .document-content-section h2 {
          color: #2c3e50;
          margin-bottom: 20px;
          font-size: 1.5rem;
        }

        .document-content {
          background: #f8f9fa;
          padding: 30px;
          border-radius: 12px;
          line-height: 1.8;
          font-size: 1.1rem;
          color: #555;
          white-space: pre-wrap;
          word-wrap: break-word;
        }

        .document-actions {
          padding: 30px;
          border-top: 2px solid #f0f0f0;
          display: flex;
          gap: 15px;
          flex-wrap: wrap;
        }

        .action-button {
          padding: 12px 24px;
          border: none;
          border-radius: 8px;
          font-size: 15px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s;
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .action-button.primary {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }

        .action-button.primary:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .action-button.secondary {
          background: #f0f0f0;
          color: #555;
        }

        .action-button.secondary:hover {
          background: #e0e0e0;
        }

        .loading-container, .error-container, .not-found {
          text-align: center;
          padding: 80px 20px;
          background: white;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .spinner {
          width: 50px;
          height: 50px;
          border: 4px solid #f3f3f3;
          border-top: 4px solid #667eea;
          border-radius: 50%;
          animation: spin 1s linear infinite;
          margin: 0 auto 20px;
        }

        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }

        .error-icon, .not-found-icon {
          font-size: 5rem;
          margin-bottom: 20px;
        }

        .error-container h2, .not-found h2 {
          color: #2c3e50;
          margin-bottom: 15px;
        }

        .error-container p, .not-found p {
          color: #7f8c8d;
          margin-bottom: 30px;
        }

        .loading-container p {
          color: #7f8c8d;
          font-size: 1.1rem;
        }

        @media (max-width: 768px) {
          .document-title {
            font-size: 1.8rem;
          }

          .document-title-section {
            flex-direction: column;
          }

          .document-actions {
            flex-direction: column;
          }

          .action-button {
            width: 100%;
            justify-content: center;
          }
        }
      `}</style>
    </div>
  );
};

export default DocumentShow;
