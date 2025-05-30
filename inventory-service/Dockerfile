FROM golang:1.22-alpine AS build
WORKDIR /src

# Copie tout (main.go + go.mod)
COPY . .

# Télécharge les dépendances et génère go.sum
RUN go mod tidy

# Compile le programme Go
RUN go build -o /bin/app .

# Étape finale : image légère
FROM alpine:3.20
COPY --from=build /bin/app /app
EXPOSE 8000
ENTRYPOINT ["/app"]
