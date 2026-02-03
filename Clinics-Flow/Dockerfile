# Multi-stage Dockerfile for backend
FROM node:20-alpine AS builder

WORKDIR /app

# Copy all package files
COPY package*.json ./

# Copy packages/database
COPY packages/database/package.json ./packages/database/

# Install all dependencies
RUN npm ci

# Copy source code
COPY apps/api ./api
COPY packages/database ./packages/database

# Build API only
WORKDIR /app/api
RUN npm run build

# Production stage - API
FROM node:20-alpine AS api-runner

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy prisma client
COPY --from=builder /app/node_modules/.prisma /app/node_modules/.prisma
COPY --from=builder /app/packages/database/prisma ./prisma/

# Copy built API
COPY --from=builder /app/apps/api/dist ./dist

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

EXPOSE 3001

CMD ["node", "dist/index.js"]
