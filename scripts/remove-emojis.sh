#!/bin/bash
# Script para eliminar emojis y mantener el proyecto profesional
# Proyecto: DINEX Tracking Individual

echo "Eliminando emojis de archivos del proyecto..."

# Lista de archivos a limpiar (excluir PROYECTO-BACKUP)
FILES=$(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yaml" -o -name "*.yml" -o -name "Makefile*" -o -name "Jenkinsfile" \) ! -path "./PROYECTO-BACKUP/*" ! -path "./scripts/remove-emojis.sh")

# Contador
COUNT=0

for file in $FILES; do
    # Eliminar emojis comunes usando sed
    # Lista completa de emojis a eliminar
    sed -i 's/🚀//g' "$file" 2>/dev/null
    sed -i 's/✅//g' "$file" 2>/dev/null
    sed -i 's/⚠️//g' "$file" 2>/dev/null
    sed -i 's/❌//g' "$file" 2>/dev/null
    sed -i 's/📊//g' "$file" 2>/dev/null
    sed -i 's/📁//g' "$file" 2>/dev/null
    sed -i 's/🔧//g' "$file" 2>/dev/null
    sed -i 's/📋//g' "$file" 2>/dev/null
    sed -i 's/🔍//g' "$file" 2>/dev/null
    sed -i 's/📦//g' "$file" 2>/dev/null
    sed -i 's/🧪//g' "$file" 2>/dev/null
    sed -i 's/🎉//g' "$file" 2>/dev/null
    sed -i 's/🎯//g' "$file" 2>/dev/null
    sed -i 's/📚//g' "$file" 2>/dev/null
    sed -i 's/🚨//g' "$file" 2>/dev/null
    sed -i 's/🔐//g' "$file" 2>/dev/null
    sed -i 's/💰//g' "$file" 2>/dev/null
    sed -i 's/📈//g' "$file" 2>/dev/null
    sed -i 's/🛡️//g' "$file" 2>/dev/null
    sed -i 's/🔴//g' "$file" 2>/dev/null
    sed -i 's/🟡//g' "$file" 2>/dev/null
    sed -i 's/🔨//g' "$file" 2>/dev/null
    sed -i 's/⏹️//g' "$file" 2>/dev/null
    sed -i 's/🧹//g' "$file" 2>/dev/null
    sed -i 's/🎓//g' "$file" 2>/dev/null
    sed -i 's/📝//g' "$file" 2>/dev/null
    sed -i 's/⚡//g' "$file" 2>/dev/null
    sed -i 's/🐳//g' "$file" 2>/dev/null
    sed -i 's/🔑//g' "$file" 2>/dev/null
    sed -i 's/🏗️//g' "$file" 2>/dev/null
    sed -i 's/📌//g' "$file" 2>/dev/null
    sed -i 's/🤖//g' "$file" 2>/dev/null

    COUNT=$((COUNT + 1))
    echo "Procesado: $file"
done

echo ""
echo "Limpieza completada. $COUNT archivos procesados."
echo "El proyecto ahora tiene un aspecto mas profesional."
