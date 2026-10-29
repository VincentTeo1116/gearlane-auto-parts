import {defineConfig} from 'vite';

export default defineConfig({
 build:{
  // Serve font files from this origin: production CSP intentionally disallows data: fonts.
  assetsInlineLimit:filePath=>/\.(?:woff2?|ttf|otf)(?:\?.*)?$/i.test(filePath)?false:undefined
 }
});
