# stage 1: builder --> bypassing the build phase as we only need the binary
# FROM golang:1.16-alpine as builder

# ENV BURROW_SRC /Users/sbanerjee/workspace/personal/Burrow/

# RUN apk add --no-cache git curl
# COPY . $BURROW_SRC
# WORKDIR $BURROW_SRC

# RUN go mod tidy && env GOOS=linux GOARCH=amd64 go build -o /tmp/burrow .
# RUN go mod tidy && go build -o /tmp/burrow .

# stage 2: runner
FROM alpine:3.13

LABEL maintainer="LinkedIn Burrow https://github.com/linkedin/Burrow"

# COPY --from=builder ./burrow/bin/burrow /app/
COPY ./bin/burrow /app/
COPY ./config/burrow.toml /etc/burrow/

CMD ["/app/burrow", "--config-dir", "/etc/burrow"]