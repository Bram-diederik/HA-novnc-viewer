ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1
FROM $BUILD_FROM

# Install requirements
RUN apk add --no-cache \
    python3 \
    py3-numpy \
    novnc \
    bash \
    sed

# English: Ensure the full VNC interface is used as the index
RUN rm -f /usr/share/novnc/index.html && \
    ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
