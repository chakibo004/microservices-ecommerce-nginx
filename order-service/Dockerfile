FROM node:20-alpine
WORKDIR /app
COPY server.js .
RUN npm init -y && npm i express prom-client
CMD ["node","server.js"]
