FROM node:12.4-alpine
WORKDIR /app
COPY package.json /app/package.json 
RUN npm install 
COPY . . 
EXPOSE 5000
CMD ["npm", "start"]
