# Use an official Node.js image as the base
FROM node:18 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy in args
ARG GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT

# Copy package.json and package-lock.json into the container
COPY package*.json ./

# Install npm dependencies
RUN npm install

# Copy the rest of the application source code into the container
COPY . .

# Clean up the dist folder and build the website
RUN rm -rf dist && npm run build && npm run build:inject

# Use an official nginx image to serve the built website
FROM nginx:alpine

# Copy the built files from the builder stage to nginx's web directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy a custom nginx configuration if needed (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for serving the website
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Start nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
