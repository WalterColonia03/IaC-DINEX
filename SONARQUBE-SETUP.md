# SonarQube - Análisis de Calidad de Código

## Configuración para DINEX Tracking Individual

Este documento describe cómo usar SonarQube para análisis estático de calidad de código en el proyecto.

---

## Prerequisitos

- Docker y Docker Compose instalados
- Node.js >= 16.x instalado
- npm instalado

---

## Comandos de Instalación y Uso

### 1. Instalar dependencias de Node.js

```bash
npm install
```

Este comando instalará `sonarqube-scanner` necesario para ejecutar el análisis.

---

### 2. Levantar servidor SonarQube

```bash
docker-compose -f docker-compose.sonar.yml up -d
```

**Tiempo de inicio:** 2-3 minutos

**Verificar que está corriendo:**
```bash
docker-compose -f docker-compose.sonar.yml ps
```

**Acceder a SonarQube:**
- URL: http://localhost:9000
- Usuario por defecto: `admin`
- Password por defecto: `admin`

**IMPORTANTE:** Al primer acceso te pedirá cambiar la contraseña.

---

### 3. Configurar token de acceso (Solo primera vez)

1. Accede a http://localhost:9000
2. Login con `admin` / `admin`
3. Cambia la contraseña cuando te lo pida
4. Ve a: My Account > Security > Generate Tokens
5. Nombre del token: `dinex-tracking`
6. Tipo: `Global Analysis Token`
7. Expira: Sin expiración
8. Haz clic en **Generate**
9. **COPIA EL TOKEN** (solo se muestra una vez)

**Configurar el token:**

Crea un archivo `.env` en la raíz del proyecto:

```bash
# En Windows (PowerShell)
echo "SONAR_TOKEN=tu-token-aqui" > .env

# En Linux/Mac
echo "SONAR_TOKEN=tu-token-aqui" > .env
```

O configura una variable de entorno:

```bash
# Windows (PowerShell)
$env:SONAR_TOKEN="tu-token-aqui"

# Linux/Mac
export SONAR_TOKEN="tu-token-aqui"
```

---

### 4. Ejecutar análisis de código

```bash
npm run sonar
```

O directamente con sonar-scanner:

```bash
npx sonar-scanner -Dsonar.login=$SONAR_TOKEN
```

**El análisis incluye:**
- Código Python en `src/`
- Configuración Terraform en `infrastructure/terraform/`
- Detección de bugs, vulnerabilidades, code smells
- Métricas de complejidad y duplicación

---

### 5. Ver resultados

1. Accede a http://localhost:9000
2. Verás el proyecto `dinex-tracking`
3. Haz clic en el proyecto para ver el análisis detallado

**Métricas disponibles:**
- Bugs
- Vulnerabilidades
- Code Smells
- Cobertura de código
- Duplicación
- Complejidad ciclomática

---

## Comandos Útiles

### Ver logs de SonarQube

```bash
docker-compose -f docker-compose.sonar.yml logs -f sonarqube
```

### Detener SonarQube

```bash
docker-compose -f docker-compose.sonar.yml down
```

### Detener y eliminar datos

```bash
docker-compose -f docker-compose.sonar.yml down -v
```

### Reiniciar SonarQube

```bash
docker-compose -f docker-compose.sonar.yml restart
```

### Ver estado de contenedores

```bash
docker-compose -f docker-compose.sonar.yml ps
```

---

## Estructura de Análisis

```
Análisis de SonarQube
│
├── src/                          # Código fuente Python
│   └── lambda/
│       ├── tracking/handler.py   # Lambda tracking
│       └── notifications/handler.py  # Lambda notifications
│
└── infrastructure/terraform/     # Código Terraform
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## Integración con CI/CD

### Agregar a Jenkinsfile

```groovy
stage('SonarQube Analysis') {
    steps {
        script {
            def scannerHome = tool 'SonarScanner'
            withSonarQubeEnv('SonarQube') {
                sh "${scannerHome}/bin/sonar-scanner"
            }
        }
    }
}
```

### Quality Gate

Para esperar el resultado del Quality Gate:

```groovy
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

---

## Configuración Avanzada

### Exclusiones personalizadas

Edita `sonar-project.properties`:

```properties
sonar.exclusions=**/*.zip,**/tests/**,**/PROYECTO-BACKUP/**
```

### Configurar umbrales de calidad

En SonarQube UI:
1. Quality Gates
2. Create
3. Define condiciones (ej: Coverage > 80%)

---

## Troubleshooting

### SonarQube no inicia

```bash
# Ver logs
docker-compose -f docker-compose.sonar.yml logs sonarqube

# Verificar recursos
docker stats

# Reiniciar
docker-compose -f docker-compose.sonar.yml restart
```

### Error: "Insufficient memory"

Aumenta la memoria de Docker:
- Docker Desktop > Settings > Resources > Memory: 4GB mínimo

### Token inválido

Regenera el token en SonarQube UI y actualiza la variable de entorno.

### Puerto 9000 en uso

Cambia el puerto en `docker-compose.sonar.yml`:

```yaml
ports:
  - "9001:9000"  # Usar puerto 9001
```

---

## Métricas Objetivo para Proyecto Universitario

| Métrica | Objetivo | Actual |
|---------|----------|--------|
| Bugs | 0 | - |
| Vulnerabilidades | 0 | - |
| Code Smells | < 10 | - |
| Cobertura | > 50% | - |
| Duplicación | < 3% | - |
| Complejidad | < 10 por función | - |

---

## Comandos Resumidos

```bash
# Setup completo
npm install
docker-compose -f docker-compose.sonar.yml up -d

# Esperar 2-3 minutos y acceder a http://localhost:9000

# Configurar token (primera vez)
# Crear token en UI y guardarlo

# Ejecutar análisis
npm run sonar

# Ver resultados en http://localhost:9000
```

---

## Limpieza

Para eliminar completamente SonarQube:

```bash
docker-compose -f docker-compose.sonar.yml down -v
docker volume prune
```

---

**Proyecto:** DINEX Tracking Individual
**Análisis estático:** SonarQube 10.3 Community
