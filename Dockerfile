FROM docker.pkg.github.com/flownative/docker-base/base:buster
MAINTAINER Robert Lemke <robert@flownative.com>

LABEL org.label-schema.name="Local Beach Dev Kit"
LABEL org.label-schema.description="Docker image providing development support for Local Beach instances"
LABEL org.label-schema.vendor="Flownative GmbH"

ENV FLOWNATIVE_LIB_PATH="/opt/flownative/lib" \
    SYNC_BASE_PATH="/opt/flownative/sync" \
    SYNC_BIN_PATH="/opt/flownative/sync/bin" \
    SYNC_TMP_PATH="/opt/flownative/sync/tmp" \
    SYNC_APPLICATION_PATH="/application" \
    SYNC_APPLICATION_ON_HOST_PATH="/application-on-host" \
    PATH="/opt/flownative/sync/bin:$PATH" \
    LOG_DEBUG=true

USER root
COPY root-files /
RUN /build.sh init && /build.sh build

USER 1000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "run" ]
