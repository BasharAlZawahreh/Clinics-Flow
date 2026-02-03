# Frontend Web Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build: application
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# Production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
