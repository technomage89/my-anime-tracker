// Import and initialize Vercel Web Analytics
import { inject } from '@vercel/analytics';

// Initialize analytics - will automatically track page views
inject({
  mode: 'auto', // Auto-detect environment (production/development)
  debug: false  // Set to true for debugging in development
});
