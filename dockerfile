# Estágio de construção
FROM golang:latest AS builder
WORKDIR /go/src/app

# Inicializa o módulo Go (substitua 'nome-do-modulo' pelo nome real do seu projeto)
RUN go mod init nome-do-modulo

# Copia o código-fonte para o diretório de trabalho
COPY . .

# Compila o código da aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o app .

# Estágio de execução
FROM scratch
COPY --from=builder /go/src/app/app /app

CMD ["/app"]
