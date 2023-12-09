# Build Stage
FROM golang:1.17-alpine3.15 AS builder

WORKDIR /app
COPY . .

# Set environment variables
ENV USER=appuser
ENV UID=10001

# Update Alpine, install dependencies, and create a non-root user
RUN cat /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache --no-progress git ca-certificates tzdata && \
    update-ca-certificates && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Build the Go application
RUN go build -ldflags '-w -s -extldflags "-static"' -a -o application main.go

# Final Stage
FROM scratch

# Set environment variables
ENV USER=appuser

# Copy necessary files from the builder stage
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app
COPY --from=builder /app ./

USER appuser
CMD ["./application"]
