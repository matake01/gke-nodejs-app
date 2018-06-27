FROM node:6.9-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./src/app /usr/src/app
RUN npm install
EXPOSE 8000
CMD npm start
