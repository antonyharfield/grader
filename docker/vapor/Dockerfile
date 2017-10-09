FROM swift:4.0

# Install Vapor Toolbox
RUN apt-get update && \
      apt-get install -y sudo wget && \
      curl -sL https://apt.vapor.sh | bash && \
      apt-get update && \
      apt-get install -y vapor mysql-client libmysqlclient-dev;

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/vapor"]
CMD ["run"]
