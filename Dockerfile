FROM nginx:stable-alpine

# Remove the default nginx welcome page.
RUN rm -rf /usr/share/nginx/html/*

# Copy the Godot Web export into the nginx image.
#
# Container layout:
#   /usr/share/nginx/html/ -> Web export, served at /
#
# The GitHub workflow stages:
#   dist/web/
COPY dist/web/ /usr/share/nginx/html/

# nginx configuration:
# - serve the Web export at /
# - keep COOP/COEP headers required for SharedArrayBuffer and Godot threads
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    # Required for Godot Web exports using SharedArrayBuffer or threads.
    add_header Cross-Origin-Opener-Policy "same-origin" always;
    add_header Cross-Origin-Embedder-Policy "require-corp" always;

    # Allows this container's resources to be loaded by cross-origin-isolated
    # pages when needed.
    add_header Cross-Origin-Resource-Policy "cross-origin" always;

    # Service workers must be revalidated.
    location ~* (service[_-]?worker|sw)\.js$ {
        try_files $uri =404;
        expires -1;
        add_header Cache-Control "no-cache" always;

        add_header Cross-Origin-Opener-Policy "same-origin" always;
        add_header Cross-Origin-Embedder-Policy "require-corp" always;
        add_header Cross-Origin-Resource-Policy "same-origin" always;
    }

    # Long-lived caching for versioned Godot-generated assets.
    location ~* \.(wasm|pck|js|png|jpg|jpeg|gif|svg|ico|ogg|mp3|wav|ttf|otf|woff|woff2)$ {
        try_files $uri =404;
        access_log off;
        expires 1y;
        add_header Cache-Control "public, immutable" always;

        add_header Cross-Origin-Opener-Policy "same-origin" always;
        add_header Cross-Origin-Embedder-Policy "require-corp" always;
        add_header Cross-Origin-Resource-Policy "cross-origin" always;
    }

    # Do not cache HTML entry points.
    location ~* \.html$ {
        try_files $uri =404;
        expires -1;
        add_header Cache-Control "no-store" always;

        add_header Cross-Origin-Opener-Policy "same-origin" always;
        add_header Cross-Origin-Embedder-Policy "require-corp" always;
        add_header Cross-Origin-Resource-Policy "same-origin" always;
    }

    # Serve the Web export at the root. Unknown routes fall back to index.html.
    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

EXPOSE 80