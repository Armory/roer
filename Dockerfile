FROM golang:1.13.4-alpine3.10 as builder

# vendor flags conflict with `go get`
# so we fetch golint before running make
# and setting the env variable
RUN apk update && apk add git make bash build-base gcc bc
RUN go get -u golang.org/x/lint/golint

ENV GO111MODULE=on GOFLAGS='-mod=vendor' GOOS=linux GOARCH=amd64
WORKDIR /opt/armory/build/
ADD ./ /opt/armory/build/

# run make
RUN go build cmd/roer/main.go
RUN mv ./main ./roer
# RUN make

FROM alpine:3.10.3

# FROM golang:1.9

WORKDIR /opt/armory/bin/
COPY --from=builder /opt/armory/build/roer /opt/armory/bin/roer

ENTRYPOINT ["/opt/armory/bin/roer"]
