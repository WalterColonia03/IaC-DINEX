# SonarQube - Guía Rápida

## Análisis de Calidad de Código para DINEX Tracking

---

## Setup en 3 Pasos

### 1. Instalar dependencias

```bash
npm install
```

### 2. Levantar SonarQube

```bash
make sonar-up
```

O sin Make:
```bash
docker-compose -f docker-compose.sonar.yml up -d
```

Espera 2-3 minutos. Luego accede a: http://localhost:9000

**Credenciales iniciales:**
- Usuario: `admin`
- Password: `admin`

Te pedirá cambiar la contraseña al primer acceso.

### 3. Configurar token (solo primera vez)

1. Login en http://localhost:9000
2. Click en tu perfil (arriba derecha) > My Account
3. Security > Generate Tokens
4. Nombre: `dinex-tracking`
5. Tipo: `Global Analysis Token`
6. Click Generate
7. COPIAR el token (solo se muestra una vez)

**Configurar en tu sistema:**

Windows PowerShell:
```powershell
$env:SONAR_TOKEN="tu-token-aqui"
```

Linux/Mac:
```bash
export SONAR_TOKEN="tu-token-aqui"
```

---

## Ejecutar Análisis

```bash
make sonar-scan
```

O sin Make:
```bash
npm run sonar
```

**Ver resultados:** http://localhost:9000

---

## Comandos Útiles

```bash
make sonar-up        # Levantar SonarQube
make sonar-down      # Detener SonarQube
make sonar-scan      # Ejecutar análisis
make sonar-logs      # Ver logs
make sonar-restart   # Reiniciar
```

---

## Lo que Analiza

- **Python:** src/lambda/tracking/handler.py, src/lambda/notifications/handler.py
- **Terraform:** infrastructure/terraform/*.tf
- **Métricas:** Bugs, vulnerabilidades, code smells, complejidad, duplicación

---

## Troubleshooting

### SonarQube no inicia

```bash
docker-compose -f docker-compose.sonar.yml logs sonarqube
docker-compose -f docker-compose.sonar.yml restart
```

### Puerto 9000 ocupado

Edita `docker-compose.sonar.yml` línea 7:
```yaml
ports:
  - "9001:9000"  # Cambiar puerto
```

### Memoria insuficiente

Docker Desktop > Settings > Resources > Memory: Mínimo 4GB

---

## Documentación Completa

Para más detalles ver: [SONARQUBE-SETUP.md](SONARQUBE-SETUP.md)
