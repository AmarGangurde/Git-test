# Use a lightweight Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for caching layer
COPY app/package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy the rest of the app
COPY app/ .

# Expose app port (adjust as needed)
EXPOSE 8000

# Run the application
CMD ["npm", "start"]

