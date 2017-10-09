FROM swift:4.0

# Install Vapor Toolbox
RUN apt-get update && \
      apt-get install -y sudo wget && \
      curl -sL https://apt.vapor.sh | bash && \
      apt-get update && \
      apt-get install -y vapor mysql-client libmysqlclient-dev;

# Install JDK
RUN apt-get update && apt-get install -y openjdk-8-jdk-headless

# Install Kotlin
WORKDIR /opt
RUN apt-get update && apt-get install -y unzip && \
    wget https://github.com/JetBrains/kotlin/releases/download/v1.1.51/kotlin-compiler-1.1.51.zip && \
    unzip kotlin-compiler-1.1.51.zip && rm kotlin-compiler-1.1.51.zip && \
    update-alternatives --install /usr/bin/kotlin kotlin /opt/kotlinc/bin/kotlin 1001 && \
    update-alternatives --install /usr/bin/kotlinc kotlinc /opt/kotlinc/bin/kotlinc 1001

# Install Python (3.5 already installed on Ubuntu 16.04)
#RUN apt-get update && apt-get install -y python3

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/vapor"]
CMD ["run"]
