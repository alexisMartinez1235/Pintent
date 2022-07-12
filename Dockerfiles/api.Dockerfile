ARG node_version

#
# Development
#
FROM node:$node_version as dev
  WORKDIR /var/app/backend

  # ADD ./*****/ /var/app/   
  VOLUME ./Backend /var/app/backend
  # ADD ./Mysql/Installation/client-cert.pem /certs/client-cert.pem 
  # See process
  RUN apk add htop

  # Needed by VsCode
  RUN apk add libstdc++
  
  RUN apk add git openssh-keygen openssh-client
 
  ### USER CONFIG ###
  RUN apk add --update sudo

  RUN echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
          && chmod 0440 /etc/sudoers.d/node
          
  RUN sudo chown node:root -R /home/node/
  ###################

  # ADD --chown=node:root ./Backend/yarn.lock .
  ADD --chown=node:root ./Backend/package.json .

  RUN yarn
  
  RUN mkdir -p node_modules/.cache && chown -R node:root node_modules/.cache
  RUN mkdir -p node_modules/.bin && chown -R node:root node_modules/.bin

  # Change owner to allow user editing
  RUN mkdir -p /home/node/.vscode-server/bin && chown -R node:root /home/node/.vscode-server
  
  # CMD yarn run build ; yarn run dev
  CMD yarn run dev

#
# Production
#

FROM node:$node_version as prod
  WORKDIR /var/app/backend
  
  VOLUME ./Backend /var/app/backend

  ### USER CONFIG ###
  RUN apk add --update sudo

  RUN echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
          && chmod 0440 /etc/sudoers.d/node
          
  RUN sudo chown node:root -R /home/node/
  ###################

  # ADD --chown=node:root ./Backend/yarn.lock .
  ADD --chown=node:root ./Backend/package.json .

  RUN yarn install --production

  RUN mkdir -p node_modules/.cache && chown -R node:root node_modules/.cache
  RUN mkdir -p node_modules/bin && chown -R node:root node_modules/bin

  # RUN yarn global add react-scripts
  # RUN sudo chown node:root -R /var/app/

  CMD yarn run build && yarn run start

  
