# Use a node base image
FROM node:18-alpine

# Set maintainer (modern format)
LABEL maintainer="miiro@getintodevops.com"

# Set a health check
HEALTHCHECK --interval=5s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:8000 || exit 1

# Tell Docker what port to expose
EXPOSE 8000

