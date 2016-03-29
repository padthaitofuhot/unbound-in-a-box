FROM alpine:{{build_alpine_version}}
MAINTAINER padthaitofuhot
{{render_alpine_mirror}}
RUN apk --no-cache add {{build_packages}}
VOLUME /opt
EXPOSE {{build_expose}}
{{render_build_entrypoint}}
{{render_build_cmd}}
