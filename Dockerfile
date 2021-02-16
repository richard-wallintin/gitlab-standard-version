FROM node:14-alpine

RUN apk --quiet --progress --update --no-cache add git openssh

RUN npm install -g standard-version@9 && npm cache clean --force

ADD gitlab-ssh-tag-version /usr/local/bin/gitlab-ssh-tag-version
ADD gitlab-compute-version /usr/local/bin/gitlab-compute-version

RUN chmod +x /usr/local/bin/gitlab-ssh-tag-version /usr/local/bin/gitlab-compute-version
