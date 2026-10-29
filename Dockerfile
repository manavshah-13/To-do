# ==============================================================================
# Multi-Stage Production Dockerfile for To-Do List Application
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Validation & Quality Gate
# ------------------------------------------------------------------------------
FROM node:20-alpine AS test-stage
WORKDIR /app

# Copy application files for syntax and integrity validation
COPY package.json index.html index.js style.css scroll.js env-config.js ./
RUN npm test && npm run lint

# ------------------------------------------------------------------------------
# Stage 2: Production NGINX Web Server
# ------------------------------------------------------------------------------
FROM nginx:1.27-alpine AS production-stage
LABEL maintainer="DevOps Team <devops@example.com>"
LABEL description="Production container for To-Do List Application"

# Remove default NGINX configuration and web assets
RUN rm -rf /etc/nginx/conf.d/* /usr/share/nginx/html/*

# Copy custom NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy application static files
COPY index.html /usr/share/nginx/html/
COPY index.js /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY scroll.js /usr/share/nginx/html/
COPY scroll_img.svg /usr/share/nginx/html/
COPY env-config.js /usr/share/nginx/html/
COPY images/ /usr/share/nginx/html/images/

# Copy and set up startup entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    touch /tmp/nginx.pid && \
    chown -R nginx:nginx /tmp/nginx.pid /var/cache/nginx /var/log/nginx

# Health Check for AWS ECS, App Runner, and Docker Compose
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q -O - http://127.0.0.1:80/health || exit 1

# Expose HTTP port
EXPOSE 80

# Use startup script to inject runtime environment variables and start NGINX
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

