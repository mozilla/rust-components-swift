FROM alpine:latest

# Add worker user
RUN mkdir -p /builds && \
    adduser -h /builds/worker -s /bin/ash -D worker && \
    mkdir /builds/worker/artifacts && \
    chown worker:worker /builds/worker/artifacts

# Update repositories
RUN apk update

# Setup Python
RUN apk add --no-cache python3 py3-pip && \
    python3 -m pip install --no-cache --upgrade --break-system-packages pip setuptools

# Setup other dependencies
RUN apk add bash git coreutils

# %include-run-task

ENV SHELL=/bin/ash \
    HOME=/builds/worker \
    PATH=/builds/worker/.local/bin:$PATH

VOLUME /builds/worker/checkouts
VOLUME /builds/worker/.cache

# Set a default command useful for debugging
CMD ["/bin/ash"]
