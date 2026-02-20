// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// React imports
import React from 'react';
import ReactDOM from 'react-dom/client';
import { createRoot } from 'react-dom/client';
// Using TypeScript version!
import DocumentShow from './components/DocumentShow.tsx';
import DocumentsList from './components/DocumentsList.tsx';

// Store React roots globally (singleton pattern)
const reactRoots = new Map();

// Initialize React components
function initializeReactComponents() {
  // Documents list page
  const documentsListElement = document.getElementById('documents-list-root');
  if (documentsListElement && !reactRoots.has('documents-list')) {
    const root = createRoot(documentsListElement);
    root.render(<DocumentsList />);
    reactRoots.set('documents-list', root);
  }

  // Document show page
  const documentShowElement = document.getElementById('document-show-root');
  if (documentShowElement && !reactRoots.has('document-show')) {
    const documentId = documentShowElement.dataset.documentId;
    const root = createRoot(documentShowElement);
    root.render(<DocumentShow documentId={documentId} />);
    reactRoots.set('document-show', root);
  }
}

// Initialize ONCE on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeReactComponents);
} else {
  // DOM already loaded
  initializeReactComponents();
}

// Make components available globally for Turbo
window.React = React;
window.ReactDOM = ReactDOM;
window.DocumentShow = DocumentShow;
window.DocumentsList = DocumentsList;
