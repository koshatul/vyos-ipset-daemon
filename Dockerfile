FROM golang:1.8-alpine
WORKDIR /go/src/github.com/koshatul/vyos-ipset-daemon
COPY . /go/src/github.com/koshatul/vyos-ipset-daemon
RUN go build -v github.com/koshatul/vyos-ipset-daemon/src/cmd/...

FROM alpine:3.7
RUN apk --update add ipset iptables
COPY --from=0 /go/src/github.com/koshatul/vyos-ipset-daemon/ipsetd /ipsetd
EXPOSE 19222/tcp
ENTRYPOINT ["/ipsetd"]
