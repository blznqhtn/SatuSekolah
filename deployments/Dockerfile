FROM golang:1.23-alpine AS builder

WORKDIR /app
# Download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the code
COPY . .
# Build the binary
RUN go build -o main cmd/server/main.go

FROM alpine:latest
WORKDIR /app

# Copy the binary and necessary resources
COPY --from=builder /app/main .
COPY --from=builder /app/.env.example .env
COPY --from=builder /app/migrations ./migrations

EXPOSE 8080
CMD ["./main"]
