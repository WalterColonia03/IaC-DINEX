#!/bin/bash
# Script para ejecutar Checkov - Análisis de seguridad IaC
# Proyecto: DINEX Tracking Individual
# Uso: ./run-checkov.sh

echo "=========================================="
echo "   CHECKOV - Análisis de Seguridad IaC"
echo "=========================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directorios
TERRAFORM_DIR="../../terraform"
RESULTS_DIR="../results"

# Crear directorio de resultados
mkdir -p "$RESULTS_DIR"

# Limpiar resultados anteriores
rm -f "$RESULTS_DIR"/*.xml "$RESULTS_DIR"/*.json

echo -e "${YELLOW}Descargando última versión de Checkov...${NC}"
docker pull bridgecrew/checkov:3

echo ""
echo -e "${YELLOW}Ejecutando análisis de seguridad en Terraform...${NC}"
echo ""

# Ejecutar Checkov y generar reporte JUnit XML
docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:3 \
  --directory /tf \
  --output junitxml \
  --output-file-path /tf/checkov-results.xml \
  --framework terraform \
  --quiet

# Mover resultados
if [ -f "$TERRAFORM_DIR/checkov-results.xml" ]; then
    mv "$TERRAFORM_DIR/checkov-results.xml" "$RESULTS_DIR/"
    echo ""
    echo -e "${GREEN}✅ Análisis completado exitosamente${NC}"
    echo ""
    echo "📊 Resultados guardados en: $RESULTS_DIR/checkov-results.xml"
    echo ""
    echo "Para visualizar los resultados:"
    echo "  1. Abre: https://lotterfriends.github.io/online-junit-parser/"
    echo "  2. Arrastra el archivo: $RESULTS_DIR/checkov-results.xml"
else
    echo -e "${RED}❌ Error: No se generaron resultados${NC}"
    exit 1
fi

# Generar reporte en JSON para análisis detallado
echo ""
echo -e "${YELLOW}Generando reporte JSON detallado...${NC}"

docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:3 \
  --directory /tf \
  --output json \
  --output-file-path /tf/checkov-results.json \
  --framework terraform \
  --quiet

if [ -f "$TERRAFORM_DIR/checkov-results.json" ]; then
    mv "$TERRAFORM_DIR/checkov-results.json" "$RESULTS_DIR/"
    echo -e "${GREEN}✅ Reporte JSON generado${NC}"
fi

# Mostrar resumen en consola
echo ""
echo "=========================================="
echo "        RESUMEN DEL ANÁLISIS"
echo "=========================================="
echo ""

docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:3 \
  --directory /tf \
  --framework terraform \
  --compact

echo ""
echo -e "${GREEN}Análisis de seguridad completado${NC}"
