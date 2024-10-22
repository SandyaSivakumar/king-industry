# Step 1: Build the app
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Install dependencies for faster build times in Docker
COPY package.json package-lock.json ./
RUN npm install

# Copy the entire project into the working directory
COPY . .

# Build the Next.js app (this will output the optimized production build)
RUN npm run build

# Step 2: Prepare production image
FROM node:18-alpine AS runner

# Set the working directory inside the container
WORKDIR /app

# Copy the build artifacts and the necessary files from the builder stage
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/package.json ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Expose the Next.js default port
EXPOSE 3000

# Set environment variable to run Next.js in production mode
ENV NODE_ENV=production

# Start the Next.js app
CMD ["npm", "run", "start"]