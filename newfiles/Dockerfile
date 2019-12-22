# base image
FROM node:13.5.0

# set working directory
WORKDIR /cake

# add node_modules to $PATH
ENV PATH /node_modules/.bin:$PATH

# install and cache app depenedencies
COPY package.json package.json
RUN npm install
RUN npm install -g @angular/cli@8.3.21

# add app
COPY . /src/app

# start app
CMD ng serve --host 0.0.0.0 -o
