ARG FRM=visigoth/grafana-unraid-stack-base'
ARG TAG='latest'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG

ENV USE_HDDTEMP no
ENV INFLUXDB_HTTP_PORT 8086
ENV INFLUXDB_RPC_PORT 58083
ENV LOKI_PORT 3100
ENV PROMTAIL_PORT 9086
ENV GRAFANA_PORT 3006

EXPOSE ${GRAFANA_PORT}/tcp \
    ${LOKI_PORT}/tcp \
    ${PROMTAIL_PORT}/tcp \
    ${INFLUXDB_HTTP_PORT}/tcp \
    ${INFLUXDB_RPC_PORT}/tcp

## build note ##
RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM}:${TAG}" >> /build.info

## install static codes ##
RUN rm -Rf /testdasi \
    && mkdir -p /temp \
    && cd /temp \
    && curl -sL "https://github.com/visigoth/static-ubuntu/releases/latest/download/archive.zip" | unzip -d /testdasi - \
    && rm -Rf /testdasi/deprecated

## execute execute execute ##
RUN /bin/bash /testdasi/scripts-install/install-grafana-unraid-stack.sh

## debug mode (comment to disable) ##
#RUN /bin/bash /testdasi/scripts-install/install-debug-mode.sh
#ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

## Final clean up ##
RUN rm -Rf /testdasi

## VEH ##
VOLUME ["/config"]
ENTRYPOINT ["tini", "--", "/static-ubuntu/grafana-unraid-stack/entrypoint.sh"]

ENV DISABLE_HEALTHCHECK=false
HEALTHCHECK CMD if [ "$DISABLE_HEALTHCHECK" = "true" ]; then exit 0; else /static-ubuntu/grafana-unraid-stack/healthcheck.sh fi
