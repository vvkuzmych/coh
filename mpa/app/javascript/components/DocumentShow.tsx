import React, { useState, useEffect } from 'react';
import './DocumentShow.css';
import { cachedFetch } from '../utils/requestCache';

// TypeScript interfaces
interface Document {
  id: string;
  title: string;
  content: string;
  status: 'uploaded' | 'reviewed' | 'signed' | 'archived' | null;
  score?: number;
}

interface ApiDocument {
  id: string;
  type: string;
  attributes: {
    title: string;
    content: string;
    status: 'uploaded' | 'reviewed' | 'signed' | 'archived' | null;
  };
}

interface ApiResponse {
  success: boolean;
  data?: ApiDocument;
  meta?: object;
  error?: {
    message: string;
    details?: string[];
  };
}

interface DocumentShowProps {
  documentId: string;
}

type StatusColor = {
  [key in Document['status']]: string;
};

type StatusIcon = {
  [key in Document['status']]: string;
};

const DocumentShow: React.FC<DocumentShowProps> = ({ documentId }) => {
  const [document, setDocument] = useState<Document | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadDocument = async () => {
      try {
        setLoading(true);
        
        // Use global cached fetch to prevent duplicates
        const response: ApiResponse = await cachedFetch(`/api/documents/${documentId}`);

        if (response.success && response.data) {
          // Transform API format to component format
          const transformedDoc: Document = {
            id: response.data.id,
            title: response.data.attributes.title,
            content: response.data.attributes.content,
            status: response.data.attributes.status
          };
          
          setDocument(transformedDoc);
          setError(null);
        } else {
          const errorMsg = response.error?.message || 'Failed to load document';
          setError(errorMsg);
        }
      } catch (err) {
        if (err instanceof Error && err.message === 'DUPLICATE_REQUEST_BLOCKED') {
          // Duplicate blocked, just stop loading
          setLoading(false);
          return;
        }
        const errorMessage = err instanceof Error ? err.message : 'Unknown error';
        setError('Network error: ' + errorMessage);
      } finally {
        setLoading(false);
      }
    };
    
    loadDocument();
  }, [documentId]);

  const getStatusColor = (status: Document['status']): string => {
    const colors: StatusColor = {
      uploaded: '#2196F3',
      reviewed: '#FF9800',
      signed: '#4CAF50',
      archived: '#F44336'
    };
    return colors[status] || '#999';
  };

  const getStatusIcon = (status: Document['status']): string => {
    const icons: StatusIcon = {
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
    </div>
  );
};

export default DocumentShow;
