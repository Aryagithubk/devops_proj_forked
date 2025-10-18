# Backend Application

Simple Node.js/Express backend for DevOps project.

## Local Development

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

## API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint
- `GET /api/message` - Sample API endpoint

## Environment Variables

Copy `.env.example` to `.env` and configure:
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
