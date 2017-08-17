FROM swift:3.1

# Install Vapor Toolbox
RUN apt-get update && \
      apt-get install -y sudo wget && \
      curl -sL https://apt.vapor.sh | bash && \
      apt-get update && \
      apt-get install -y vapor;
