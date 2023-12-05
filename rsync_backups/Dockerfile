ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk update
RUN apk add --no-cache jq openssh-client openssh-keygen rsync

# Generate new key
RUN ssh-keygen -q -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "hassio"

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
