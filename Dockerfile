# Stage 1: Build React app
FROM node:16-alpine AS build

# Custom working directory (with -docker at the end)
WORKDIR /dockerized-deployment-all-clouds-docker

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies (ignore peer deps conflicts for React 17)
RUN npm install --legacy-peer-deps

# Copy all project files
COPY . .

# Build React app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy build output from builder
COPY --from=build /dockerized-deployment-all-clouds-docker/build /usr/share/nginx/html

# Copy custom nginx config (SPA fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

