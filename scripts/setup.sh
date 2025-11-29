#!/bin/bash
# Setup inicial para DINEX Tracking
# Proyecto universitario individual
# Ejecutar una vez al iniciar el proyecto

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "   DINEX Tracking - Setup Inicial"
echo "=========================================="
echo ""

# Verificar prerequisitos
echo -e "${YELLOW}📋 Verificando prerequisitos...${NC}"
echo ""

# Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no instalado${NC}"
    echo "   Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo -e "${GREEN}✅ Docker instalado$(NC)"

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose no encontrado (incluido en Docker Desktop)${NC}"
fi

# Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}⚠️  Terraform no instalado${NC}"
    echo "   Instala desde: https://www.terraform.io/downloads"
else
    echo -e "${GREEN}✅ Terraform instalado: $(terraform version | head -n1)${NC}"
fi

# Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 no instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python 3 instalado: $(python3 --version)${NC}"

# AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}⚠️  AWS CLI no instalado${NC}"
    echo "   Instala desde: https://aws.amazon.com/cli/"
else
    echo -e "${GREEN}✅ AWS CLI instalado: $(aws --version | cut -d' ' -f1)${NC}"
fi

echo ""
echo -e "${YELLOW}📁 Creando estructura de directorios...${NC}"

# Crear directorios necesarios
mkdir -p infrastructure/security/results
mkdir -p application/tests
mkdir -p monitoring/grafana/provisioning/dashboards
mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p jenkins/jobs
mkdir -p logs

echo -e "${GREEN}✅ Directorios creados${NC}"

# Instalar dependencias Python
echo ""
echo -e "${YELLOW}📦 Instalando dependencias Python...${NC}"

pip3 install --user --upgrade pip
pip3 install --user boto3 pytest pytest-cov

echo -e "${GREEN}✅ Dependencias Python instaladas${NC}"

# Dar permisos de ejecución
echo ""
echo -e "${YELLOW}🔧 Configurando permisos de scripts...${NC}"

chmod +x infrastructure/security/checkov/*.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}✅ Permisos configurados${NC}"

# Inicializar Terraform
echo ""
echo -e "${YELLOW}🏗️  Inicializando Terraform...${NC}"

cd infrastructure/terraform
terraform init -backend=false
cd ../..

echo -e "${GREEN}✅ Terraform inicializado${NC}"

# Crear .gitignore si no existe
if [ ! -f .gitignore ]; then
    echo ""
    echo -e "${YELLOW}📝 Creando .gitignore...${NC}"
    cat > .gitignore << 'EOF'
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
*.tfplan

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/

# Lambda
deployment.zip

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Security
*.pem
*.key
.aws/
credentials

# Docker
docker-compose.override.yml

# Jenkins
jenkins_home/

# Checkov results
infrastructure/security/results/*.xml
infrastructure/security/results/*.json
EOF
    echo -e "${GREEN}✅ .gitignore creado${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Setup completado exitosamente!${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}📚 Próximos pasos:${NC}"
echo ""
echo "  1. Configura tus credenciales AWS:"
echo "     $ aws configure"
echo ""
echo "  2. Personaliza terraform.tfvars con tu información"
echo ""
echo "  3. Ejecuta análisis de seguridad:"
echo "     $ make security"
echo ""
echo "  4. Levanta el stack de monitoreo:"
echo "     $ make monitor-up"
echo ""
echo "  5. Construye y ejecuta Jenkins:"
echo "     $ make jenkins-build"
echo "     $ make jenkins-run"
echo ""
echo "  6. Despliega la infraestructura:"
echo "     $ make deploy-all"
echo ""
echo -e "Para ver todos los comandos disponibles: ${GREEN}make help${NC}"
echo ""
