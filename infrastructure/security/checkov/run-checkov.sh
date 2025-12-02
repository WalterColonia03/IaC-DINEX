#!/bin/bash
# Análisis de seguridad con Checkov

TERRAFORM_DIR="../../terraform"
RESULTS_DIR="../results"

mkdir -p "$RESULTS_DIR"
rm -f "$RESULTS_DIR"/*.xml "$RESULTS_DIR"/*.json

echo "Ejecutando Checkov..."

docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:latest \
  --directory /tf \
  --framework terraform \
  --output cli

echo "Generando reporte XML..."

docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:latest \
  --directory /tf \
  --framework terraform \
  --output junitxml \
  --output-file-path /tf/checkov-results.xml \
  --quiet

if [ -f "$TERRAFORM_DIR/checkov-results.xml" ]; then
    mv "$TERRAFORM_DIR/checkov-results.xml" "$RESULTS_DIR/"
    echo "Reporte guardado: $RESULTS_DIR/checkov-results.xml"
else
    echo "Error: No se generó reporte"
    exit 1
fi

echo "Análisis completado"
