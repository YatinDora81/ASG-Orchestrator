FROM codercom/code-server:4.96.4

USER root

RUN apt-get update \
    && apt-get install -y curl xz-utils \
    && curl -fsSL https://nodejs.org/dist/v24.5.0/node-v24.5.0-linux-x64.tar.xz -o node.tar.xz \
    && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz \
    && node -v \
    && npm -v

RUN node -v

# Clone React project (root clones, coder owns)
RUN git clone https://github.com/YatinDora81/react-tailwind-starter.git /home/coder/react-starter
RUN chown -R coder:coder /home/coder/react-starter

# Switch to coder
USER coder

# Work inside project
WORKDIR /home/coder/react-starter
RUN npm install

EXPOSE 8080
EXPOSE 5173

# Remove old config to prevent password prompt
RUN rm -rf /home/coder/.config/code-server

# Default dark theme
RUN mkdir -p /home/coder/.local/share/code-server/User && \
    echo '{"workbench.colorTheme": "Default Dark+", "workbench.preferredDarkColorTheme": "Default Dark+"}' > /home/coder/.local/share/code-server/User/settings.json && \
    chmod 644 /home/coder/.local/share/code-server/User/settings.json

# Create the startup script AS coder (not root)
RUN printf "%s\n" '#!/bin/bash' \
'exec code-server --auth none --bind-addr 0.0.0.0:8080 /home/coder/react-starter' \
> /home/coder/start.sh

# Back to root to chmod
USER root
RUN chmod +x /home/coder/start.sh

# Final user must be coder so code-server does NOT require password
USER coder

CMD ["/bin/bash", "/home/coder/start.sh"]
