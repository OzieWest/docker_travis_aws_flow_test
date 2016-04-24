FROM soramusoka/nodejs
WORKDIR /app
ADD . /app
RUN npm install
CMD ["npm", "start"]

