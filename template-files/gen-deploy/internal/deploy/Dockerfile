FROM golang:alpine as builder
# Install make and certificates
#RUN apk --no-cache add tzdata zip ca-certificates make git
# Make repository path
RUN mkdir -p /tmp/target
WORKDIR  /tmp/target
# Copy Makefile first, it will save time during development.
# COPY ./Makefile ./Makefile
# Copy all project files
ADD . .
WORKDIR __SERVICE_DIR__
# Generate a binary
RUN go get -d -v
RUN apk add make
RUN make build
# Second (final) stage, base image is scratch
FROM alpine
RUN apk add --no-cache ca-certificates
RUN apk add --update tzdata
ENV TZ=UTC
ENV CONFIGPATH=/configs
# Copy statically linked binary
# Copy statically linked binary
COPY --from=builder /tmp/target/__SERVICE_DIR__/bin/main /main
COPY --from=builder /tmp/target/configs /configs
# Copy SSL certificates, eventhough we don't need it for this example
# but if you decide to talk to HTTPS sites, you'll need this.
#COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Notice "CMD", we don't use "Entrypoint" because there is no OS
EXPOSE 5000
CMD ["/main" ]
