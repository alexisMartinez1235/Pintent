ARG node_version
#
# Development
#

FROM node:$node_version AS dev

  WORKDIR /var/app/frontend

  # ADD ./******/ /var/app/ 
  
  VOLUME ./Frontend /var/app/frontend
  # ADD ./Mysql/Installation/client-cert.pem /certs/client-cert.pem 
  
  # for See process
  RUN apk add htop

  # Needed by VsCode
  RUN apk add libstdc++
  
  ### USER CONFIG ###
  RUN apk add --update sudo
  RUN apk add git openssh-keygen openssh-client
 
  RUN echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
          && chmod 0440 /etc/sudoers.d/node
          
  RUN chown node:root -R /home/node/
  ###################i

  # ADD --chown=node:root ./Frontend/yarn.lock .
  ADD --chown=node:root ./Frontend/package.json .
  
  RUN yarn  
  RUN yarn global add react-scripts@4.0.3 typescript@4.6.4 @typescript-eslint/eslint-plugin@5.23.0
  
  RUN mkdir -p node_modules/.cache && chown -R node:root node_modules/.cache
  RUN mkdir -p node_modules/.bin && chown -R node:root node_modules/.bin

  # Change owner to allow user editing
  RUN mkdir -p /home/node/.vscode-server/bin && chown -R node:root /home/node/.vscode-server
  
  # CMD yarn run build ; yarn run start
  
  CMD yarn run start || sleep 3000
  # CMD sleep 10000
#
# Production
#

FROM node:$node_version AS prod
  WORKDIR /var/app/frontend

  VOLUME ./Frontend /var/app/frontend
  
  ### USER CONFIG ###
  RUN apk add --update sudo

  RUN echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node \
          && chmod 0440 /etc/sudoers.d/node
  RUN sudo chown node:root -R /home/node/
  ###################

  # ADD --chown=node:root ./Frontend/yarn.lock .
  ADD --chown=node:root ./Frontend/package.json .

  RUN yarn install --production
  RUN yarn global add react-scripts@4.0.3 typescript@4.6.4

  RUN mkdir -p node_modules/.cache && chown -R node:root node_modules/.cache
  RUN mkdir -p node_modules/.bin && chown -R node:root node_modules/.bin
  
  CMD yarn run build && yarn run start
 
