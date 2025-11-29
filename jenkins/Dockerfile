# Jenkins personalizado para DINEX Tracking
# Incluye: Terraform, Python, Docker

FROM jenkins/jenkins:lts

# Cambiar a root para instalar paquetes
USER root

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    docker.io \
    make \
    zip \
    unzip \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Instalar Terraform
ARG TERRAFORM_VERSION=1.6.0
RUN wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin/ \
    && rm /tmp/terraform.zip \
    && chmod +x /usr/local/bin/terraform

# Instalar herramientas Python
RUN pip3 install --no-cache-dir boto3 pytest pytest-cov

# Volver a usuario jenkins
USER jenkins

# Copiar lista de plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar plugins de Jenkins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copiar configuración JCasC
COPY casc.yaml /var/jenkins_home/casc.yaml

# Variables de entorno para Configuration as Code
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Exponer puertos
EXPOSE 8080 50000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/login || exit 1
