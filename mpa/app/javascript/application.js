// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// React imports
import React from 'react';
import { createRoot } from 'react-dom/client';
import DocumentShow from './components/DocumentShow';

// Initialize React components
function initializeReactComponents() {
  const documentShowElement = document.getElementById('document-show-root');
  if (documentShowElement) {
    const documentId = documentShowElement.dataset.documentId;
    const root = createRoot(documentShowElement);
    root.render(<DocumentShow documentId={documentId} />);
  }
}

// Listen to both DOMContentLoaded AND turbo:load
document.addEventListener('DOMContentLoaded', initializeReactComponents);
document.addEventListener('turbo:load', initializeReactComponents);

// Cleanup on turbo:before-render to prevent duplicates
document.addEventListener('turbo:before-render', (event) => {
  const documentShowElement = document.getElementById('document-show-root');
  if (documentShowElement) {
    // Unmount React component before Turbo renders
    const root = documentShowElement._reactRoot;
    if (root) {
      root.unmount();
    }
  }
});

// Make components available globally for Turbo
window.React = React;
window.DocumentShow = DocumentShow;
