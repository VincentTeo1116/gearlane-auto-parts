import React from 'react';
import {createRoot} from 'react-dom/client';
import App from './App.jsx';
import {ErrorBoundary} from './components.jsx';
import './styles.css';
import './details.css';
createRoot(document.getElementById('root')).render(<ErrorBoundary><App/></ErrorBoundary>);
