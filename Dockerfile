# 1.23과 sqllite3 오류
# FROM golang:1.19-alpine3.15 AS builder
FROM golang:1.23-alpine3.19 AS builder
# FROM golang:1.23-bookworm AS builder

LABEL maintainer="erguotou525@gmail.compute"

RUN apk upgrade --no-cache
RUN apk --no-cache add git libc-dev gcc
# RUN apk add --update gcc musl-dev make g++ sqlite-dev
# RUN apt-get update && \
#     apt-get install -y \
#         git \
#         build-essential \
#         libsqlite3-dev \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
    
COPY . /go/src/github.com/mailslurper

WORKDIR /go/src/github.com/mailslurper

RUN go mod tidy
RUN go mod download
RUN go mod vendor

RUN go build ./cmd/mailslurper
# RUN CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 go build -a -v ./cmd/mailslurper
# RUN CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 go build ./cmd/mailslurper


FROM alpine

RUN apk add --no-cache ca-certificates \
 && echo -e '{\n\
  "wwwAddress": "0.0.0.0",\n\
  "wwwPort": 8080,\n\
  "wwwPublicURL": "",\n\
  "serviceAddress": "0.0.0.0",\n\
  "servicePort": 8085,\n\
  "servicePublicURL": "",\n\
  "smtpAddress": "0.0.0.0",\n\
  "smtpPort": 2500,\n\
  "dbEngine": "SQLite",\n\
  "dbHost": "",\n\
  "dbPort": 0,\n\
  "dbDatabase": "./mailslurper.db",\n\
  "dbUserName": "",\n\
  "dbPassword": "",\n\
  "maxWorkers": 1000,\n\
  "autoStartBrowser": false,\n\
  "keyFile": "",\n\
  "certFile": "",\n\
  "adminKeyFile": "",\n\
  "adminCertFile": ""\n\
  }'\
  >> config.json

WORKDIR /app

COPY --from=builder /go/src/github.com/mailslurper/mailslurper .
COPY --from=builder /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper/config.json .
COPY --from=builder /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper/version.json .

EXPOSE 8080 8085 2500

CMD ["./mailslurper"]
