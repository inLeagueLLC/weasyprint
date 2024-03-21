FROM python:3-alpine3.18

RUN apk upgrade --no-cache && apk add --no-cache uwsgi uwsgi-python3

# Fix missing "getrandom"
RUN apk add --no-cache musl\>1.1.20 --repository http://dl-cdn.alpinelinux.org/alpine/latest-stable/main

RUN \
  apk update && \
  apk add --virtual .build-deps gcc musl-dev jpeg-dev zlib-dev libffi-dev && \
  apk add cairo-dev pango-dev gdk-pixbuf cairo ttf-freefont ttf-font-awesome && \
  pip3 install --upgrade pip && \
  pip3 install cffi cssselect2 cairosvg cairocffi WeasyPrint gunicorn flask dumb-init && \
  apk del .build-deps && \
  rm -f /var/cache/apk/*

RUN fc-cache

EXPOSE 80

WORKDIR /srv/weasyprint
COPY tools.py ./

ENTRYPOINT ["dumb-init", "--"]

ENV WEASY_APP=tools:prod
ENV WEASY_USER=uwsgi
ENV WEASY_GROUP=uwsgi
CMD gunicorn --bind 0.0.0.0:80 -u "$WEASY_USER" -g "$WEASY_GROUP" --timeout 90 --graceful-timeout 60 "$WEASY_APP"
