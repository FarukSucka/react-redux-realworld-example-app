FROM nginx:1.17.10-alpine as staging
COPY /scripts/nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/share/nginx/html/
COPY /dist/staging .

FROM nginx:1.17.10-alpine as production
COPY /scripts/nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/share/nginx/html/
COPY /dist/production .