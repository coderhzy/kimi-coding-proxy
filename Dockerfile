FROM node:20-alpine

WORKDIR /app

COPY proxy.js .
COPY config.json .

EXPOSE 8919

CMD ["node", "proxy.js"]
