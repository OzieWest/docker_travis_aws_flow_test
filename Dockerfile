FROM node:boron
WORKDIR /app

RUN cd /opt \
      && mkdir jq \
      && wget -O ./jq/jq http://stedolan.github.io/jq/download/linux64/jq \
      && chmod +x ./jq/jq \
      && ln -s /opt/jq/jq /usr/local/bin

ADD . /app
RUN npm install
CMD ["/bin/sh", "./start.sh"]

