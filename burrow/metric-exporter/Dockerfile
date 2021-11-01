# Stage 1 - builder --> Bypassing this as we don't need to build from source
# FROM golang:1.13-alpine AS builder

# RUN apk --no-cache add git make

# WORKDIR /src/burrow_exporter
# COPY . .
# RUN make build

# Stage 2
FROM busybox
LABEL maintainer "Alex Simenduev <shamil.si@gmail.com>"

# ENTRYPOINT ["burrow_exporter"]

# COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY ./bin/burrow_exporter /usr/local/bin/
CMD ["/usr/local/bin/burrow_exporter", "--burrow.address", "http://burrow:8000", "--web.listen-address", ":8237"]
