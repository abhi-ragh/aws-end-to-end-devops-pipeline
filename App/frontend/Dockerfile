FROM node:18-alpine AS build
WORKDIR /app
ENV NODE_OPTIONS=--openssl-legacy-provider
COPY package.json /app/package.json 
RUN npm install 
COPY . . 

# Do not set REACT_APP_API_URL at build time — frontend uses relative paths.
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
