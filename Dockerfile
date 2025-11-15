FROM node:17-alpine
WORKDIR /app
COPY . .
RUN npm install -g http-server
CMD ["http-server", "-p", "5050", "-a", "0.0.0.0"]
EXPOSE 5050
