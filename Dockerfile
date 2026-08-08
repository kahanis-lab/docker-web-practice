FROM nginx:alpine

LABEL org.opencontainers.image.title="docker-web-practice"
LABEL org.opencontainers.image.description="Static Nginx web server for Docker practice"

COPY site/ /usr/share/nginx/html/

EXPOSE 80