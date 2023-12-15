FROM golang:latest AS builder

WORKDIR /go/src/app

RUN go mod init nome-do-modulo

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o app .

FROM scratch
COPY --from=builder /go/src/app/app /app

CMD ["/app"]
