import React, { useState, useEffect } from 'react';
import './DocumentsList.css';
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
  data?: ApiDocument[];
  meta?: {
    total_count: number;
    current_page: number;
    per_page: number;
    total_pages: number;
  };
  error?: {
    message: string;
    details?: string[];
  };
}

const DocumentsList: React.FC = () => {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const loadDocuments = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Use global cached fetch to prevent duplicates
      const response: ApiResponse = await cachedFetch('/api/documents');

      if (response.success && response.data) {
        // Transform API format to component format
        const transformedDocs: Document[] = response.data.map(doc => ({
          id: doc.id,
          title: doc.attributes.title,
          content: doc.attributes.content,
          status: doc.attributes.status
        }));
        
        setDocuments(transformedDocs);
        setError(null);
      } else {
        const errorMsg = response.error?.message || 'Failed to load documents';
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

  useEffect(() => {
    loadDocuments();
  }, []);

  const getStatusColor = (status: Document['status']): string => {
    const colors = {
      uploaded: '#2196F3',
      reviewed: '#FF9800',
      signed: '#4CAF50',
      archived: '#F44336'
    };
    return colors[status] || '#999';
  };

  const getStatusIcon = (status: Document['status']): string => {
    const icons = {
      uploaded: '📤',
      reviewed: '👁️',
      signed: '✅',
      archived: '📦'
    };
    return icons[status] || '📄';
  };

  const truncateContent = (content: string, maxLength: number = 150): string => {
    if (content.length <= maxLength) return content;
    return content.substring(0, maxLength) + '...';
  };

  if (loading) {
    return (
      <div className="documents-list">
        <div className="loading-container">
          <div className="spinner"></div>
          <p>Loading documents...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="documents-list">
        <div className="error-container">
          <div className="error-icon">⚠️</div>
          <h2>Error</h2>
          <p>{error}</p>
          <button onClick={loadDocuments} className="retry-button">
            🔄 Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="documents-list">
      {/* Header */}
      <div className="documents-header">
        <h1>📚 Documents</h1>
        <div className="documents-count">
          Total: {documents.length} document{documents.length !== 1 ? 's' : ''}
        </div>
      </div>

      {/* Documents Grid */}
      {documents.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">📭</div>
          <h2>No Documents Found</h2>
          <p>There are no documents available.</p>
        </div>
      ) : (
        <div className="documents-grid">
          {documents.map((doc) => (
            <a 
              key={doc.id}
              href={`/documents/${doc.id}`}
              className="document-card"
              data-turbo="false"
            >
              <div className="document-card-header">
                <h3 className="document-title">{doc.title}</h3>
                <div 
                  className="status-badge"
                  style={{ backgroundColor: getStatusColor(doc.status) }}
                >
                  {getStatusIcon(doc.status)} {doc.status?.toUpperCase() || 'UNKNOWN'}
                </div>
              </div>
              
              <div className="document-content-preview">
                {truncateContent(doc.content)}
              </div>

              <div className="document-card-footer">
                <span className="document-id">ID: {doc.id}</span>
                <span className="view-link">View →</span>
              </div>
            </a>
          ))}
        </div>
      )}
    </div>
  );
};

export default DocumentsList;
