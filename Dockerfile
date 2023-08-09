FROM golang:1.18.6-alpine as builder
#ENV CGO_ENABLED=0
COPY . /flowerss
RUN apk add git make gcc libc-dev && \
    cd /flowerss && make build

# Image starts here
FROM alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /flowerss/flowerss-bot /bin/
ARG rcloneconfig
RUN apk add --no-cache rclone cron;echo $rcloneconfig > /root/.config/rclone/rclone.conf;
RUN touch .initialized && rclone copy backup:/flowerss /root/.flowerss && (crontab -l;echo "0 0 * * * rclone sync /root/.flowerss backup:/flowerss > /dev/null 2>&1 ") | crontab
VOLUME /root/.flowerss
WORKDIR /root/.flowerss
ENTRYPOINT ["/bin/flowerss-bot"]
