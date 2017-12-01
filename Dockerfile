FROM node:8
ADD . /app
WORKDIR /app
RUN npm install && \
npm install -g gulp && \
npm install coffeescript@next
EXPOSE 3000
CMD ["gulp"]
