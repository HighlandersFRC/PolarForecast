# Use the official Node.js image with the specific version
FROM node:21.5.0

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) files
COPY package*.json ./

# Install dependencies
RUN npm install


COPY . .


# Expose the port your app runs on
EXPOSE 3000

# Define the command to run your application
CMD ["npm", "start"]
