FROM codercom/code-server:4.96.4

USER root

# Install Node.js
RUN apt-get update \
    && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN node -v

# Clone React project (root clones, coder owns)
RUN git clone https://github.com/hayyi2/react-shadcn-starter.git /home/coder/react-starter
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

# Create the startup script AS coder (not root)
RUN printf "%s\n" '#!/bin/bash' \
'cd /home/coder/react-starter' \
'npm run dev ' \
'exec code-server --auth none --bind-addr 0.0.0.0:8080 /home/coder/react-starter' \
> /home/coder/start.sh

# Back to root to chmod
USER root
RUN chmod +x /home/coder/start.sh

# Final user must be coder so code-server does NOT require password
USER coder

CMD ["/bin/bash", "/home/coder/start.sh"]
