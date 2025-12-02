#!/bin/bash
# Script de verificación del proyecto DINEX Tracking
# Verifica que todo esté configurado correctamente

echo "======================================"
echo "  VERIFICACIÓN PROYECTO DINEX"
echo "======================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ERROR_COUNT=0

# Verificar Node.js
echo -n "Verificando Node.js... "
if command -v node &> /dev/null; then
    VERSION=$(node --version)
    echo -e "${GREEN}OK${NC} - $VERSION"
else
    echo -e "${RED}ERROR${NC} - Node.js no instalado"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Verificar npm
echo -n "Verificando npm... "
if command -v npm &> /dev/null; then
    VERSION=$(npm --version)
    echo -e "${GREEN}OK${NC} - v$VERSION"
else
    echo -e "${RED}ERROR${NC} - npm no instalado"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Verificar Docker
echo -n "Verificando Docker... "
if command -v docker &> /dev/null; then
    VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    echo -e "${GREEN}OK${NC} - $VERSION"
else
    echo -e "${RED}ERROR${NC} - Docker no instalado"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Verificar Docker Compose
echo -n "Verificando Docker Compose... "
if command -v docker-compose &> /dev/null; then
    VERSION=$(docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)
    echo -e "${GREEN}OK${NC} - $VERSION"
else
    echo -e "${RED}ERROR${NC} - Docker Compose no instalado"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Verificar Terraform
echo -n "Verificando Terraform... "
if command -v terraform &> /dev/null; then
    VERSION=$(terraform version | head -n1 | cut -d'v' -f2)
    echo -e "${GREEN}OK${NC} - v$VERSION"
else
    echo -e "${YELLOW}ADVERTENCIA${NC} - Terraform no instalado"
fi

# Verificar AWS CLI
echo -n "Verificando AWS CLI... "
if command -v aws &> /dev/null; then
    VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
    echo -e "${GREEN}OK${NC} - $VERSION"
else
    echo -e "${YELLOW}ADVERTENCIA${NC} - AWS CLI no instalado"
fi

echo ""
echo "======================================"
echo "  ESTRUCTURA DEL PROYECTO"
echo "======================================"
echo ""

# Verificar directorios principales
DIRS=(
    "src/lambda/tracking"
    "src/lambda/notifications"
    "application/lambda/tracking"
    "application/lambda/notifications"
    "infrastructure/terraform"
    "infrastructure/security/checkov"
    "monitoring/grafana"
    "monitoring/prometheus"
    "monitoring/loki"
    "jenkins"
    "scripts"
)

for dir in "${DIRS[@]}"; do
    echo -n "Verificando $dir... "
    if [ -d "$dir" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}NO EXISTE${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

echo ""
echo "======================================"
echo "  ARCHIVOS DE CONFIGURACIÓN"
echo "======================================"
echo ""

# Verificar archivos clave
FILES=(
    "package.json"
    "sonar-project.properties"
    "docker-compose.sonar.yml"
    ".env.example"
    "Makefile"
    "infrastructure/terraform/main.tf"
    "SONARQUBE-SETUP.md"
    "COMANDOS-SONARQUBE.md"
    "PROYECTO-COMPLETO.md"
)

for file in "${FILES[@]}"; do
    echo -n "Verificando $file... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}NO EXISTE${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

echo ""
echo "======================================"
echo "  DEPENDENCIAS NODE.JS"
echo "======================================"
echo ""

if [ -d "node_modules" ]; then
    echo -e "${GREEN}node_modules existe${NC}"

    if [ -f "node_modules/sonarqube-scanner/package.json" ]; then
        echo -e "${GREEN}sonarqube-scanner instalado${NC}"
    else
        echo -e "${YELLOW}sonarqube-scanner NO instalado${NC}"
        echo "Ejecuta: npm install"
    fi
else
    echo -e "${YELLOW}node_modules NO existe${NC}"
    echo "Ejecuta: npm install"
fi

echo ""
echo "======================================"
echo "  SERVICIOS DOCKER"
echo "======================================"
echo ""

# Verificar si Docker está corriendo
if docker info &> /dev/null; then
    echo -e "${GREEN}Docker daemon corriendo${NC}"

    # Verificar contenedores de SonarQube
    if docker ps | grep -q "dinex-sonarqube"; then
        echo -e "${GREEN}SonarQube corriendo${NC}"
    else
        echo -e "${YELLOW}SonarQube NO corriendo${NC}"
        echo "Ejecuta: make sonar-up"
    fi

    # Verificar contenedores de monitoreo
    if docker ps | grep -q "dinex-grafana"; then
        echo -e "${GREEN}Grafana corriendo${NC}"
    else
        echo -e "${YELLOW}Grafana NO corriendo${NC}"
        echo "Ejecuta: docker-compose up -d"
    fi
else
    echo -e "${RED}Docker daemon NO corriendo${NC}"
    echo "Inicia Docker Desktop"
fi

echo ""
echo "======================================"
echo "  RESUMEN"
echo "======================================"
echo ""

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${GREEN}Proyecto verificado correctamente${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Si no lo hiciste: npm install"
    echo "2. Levantar SonarQube: make sonar-up"
    echo "3. Configurar token en http://localhost:9000"
    echo "4. Ejecutar análisis: make sonar-scan"
else
    echo -e "${RED}Se encontraron $ERROR_COUNT errores${NC}"
    echo ""
    echo "Revisa los mensajes de error arriba y corrige los problemas"
fi

echo ""
