# Sistema de Tracking DINEX - Proyecto Individual con DevOps

## Proyecto Universitario - Infraestructura como Código

**Estudiante:** [Tu Nombre]
**Curso:** Infraestructura como Código
**Universidad:** [Tu Universidad]
**Año:** 2025

---

## Descripción del Proyecto

Sistema de tracking de entregas en tiempo real para DINEX Perú, implementado con arquitectura serverless en AWS, Infrastructure as Code con Terraform, y stack completo de DevOps incluyendo:

- **Infraestructura:** Terraform (IaC)
- **Seguridad:** Checkov (análisis estático)
- **Monitoreo:** Grafana + Prometheus + Loki
- **CI/CD:** Jenkins con Configuration as Code
- **Cloud:** AWS (Lambda, DynamoDB, API Gateway, CloudWatch, SNS)

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO/CLIENTE                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │  API Gateway    │  ← HTTP API (v2)
            │  (4 endpoints)  │
            └────────┬────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
  ┌───────────────┐     ┌───────────────┐
  │  Lambda       │     │  Lambda       │
  │  Tracking     │     │  Notifications│
  └───────┬───────┘     └───────┬───────┘
          │                     │
          │                     ▼
          │             ┌───────────────┐
          │             │  SNS Topic    │
          │             │  (Notificaciones)
          │             └───────────────┘
          │
          ▼
  ┌───────────────┐
  │  DynamoDB     │
  │  (NoSQL)      │
  │  - tracking_id│
  │  - timestamp  │
  │  - location   │
  └───────┬───────┘
          │
          ▼
  ┌───────────────┐
  │  CloudWatch   │
  │  - Logs       │
  │  - Metrics    │
  │  - Dashboard  │
  │  - Alarms     │
  └───────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    STACK DE DEVOPS LOCAL                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────┐  ┌─────────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Grafana   │  │ Prometheus  │  │   Loki   │  │ Promtail │  │
│  │ :3000      │  │ :9090       │  │ :3100    │  │          │  │
│  └────────────┘  └─────────────┘  └──────────┘  └──────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Jenkins CI/CD                                          │   │
│  │  :8080                                                  │   │
│  │  - Configuration as Code (JCasC)                       │   │
│  │  - Docker Agents                                        │   │
│  │  - Pipelines automatizados                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Checkov Security Scanner                               │   │
│  │  - Análisis estático de IaC                            │   │
│  │  - Reportes JUnit XML                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Estructura del Proyecto

```
dinex-tracking-project/
│
├── README.md                           # Documentación principal original
├── README-DEVOPS.md                    # Documentación DevOps (este archivo)
├── Makefile                           # Makefile original
├── Makefile-DevOps                    # Makefile extendido con DevOps
├── Jenkinsfile                        # Pipeline CI/CD
├── docker-compose.yml                 # Stack de monitoreo
├── .gitignore                         # Exclusiones Git
│
├── infrastructure/                    # Infraestructura como Código
│   ├── terraform/                    # Configuración Terraform
│   │   ├── main.tf                  # Recursos principales AWS
│   │   ├── variables.tf             # Variables de configuración
│   │   ├── outputs.tf               # Outputs del deployment
│   │   ├── terraform.tfvars         # Valores de variables
│   │   └── versions.tf              # Versiones de providers
│   │
│   └── security/                     # Seguridad y análisis
│       └── checkov/
│           ├── run-checkov.sh       # Script análisis Checkov
│           ├── .checkov.yml         # Configuración Checkov
│           └── results/             # Resultados de análisis
│
├── application/                       # Código de la aplicación
│   ├── lambda/                       # Funciones Lambda
│   │   ├── tracking/                # Función de tracking
│   │   │   ├── index.py            # Handler Python
│   │   │   └── deployment.zip      # Package para deployment
│   │   │
│   │   └── notifications/           # Función de notificaciones
│   │       ├── index.py
│   │       └── deployment.zip
│   │
│   └── tests/                       # Tests unitarios
│       └── test_tracking.py        # Tests de tracking
│
├── monitoring/                        # Stack de Observabilidad
│   ├── grafana/
│   │   └── provisioning/
│   │       ├── dashboards/         # Dashboards Grafana
│   │       │   └── dashboard.yml
│   │       └── datasources/        # Datasources (Prometheus, Loki)
│   │           └── datasources.yml
│   │
│   ├── prometheus/
│   │   └── prometheus.yml          # Config Prometheus
│   │
│   ├── loki/
│   │   └── loki-config.yml         # Config Loki
│   │
│   └── promtail/
│       └── promtail-config.yml     # Config Promtail
│
├── jenkins/                          # CI/CD con Jenkins
│   ├── Dockerfile                  # Imagen personalizada
│   ├── plugins.txt                 # Plugins a instalar
│   ├── casc.yaml                  # Configuration as Code
│   └── jobs/                      # Jobs predefinidos
│
├── scripts/                         # Scripts de utilidad
│   └── setup.sh                   # Setup inicial
│
└── docs/                           # Documentación
    ├── GUIA_CONFIGURACION_AWS.md  # Guía AWS
    ├── ERRORES_ENCONTRADOS.md     # Reporte de errores
    ├── EXPLICACION_PASO_A_PASO.md # Explicación detallada
    └── RESUMEN-PROYECTO-INDIVIDUAL.md # Resumen presentación
```

---

## Tecnologías Utilizadas

### Infrastructure as Code
- **Terraform 1.6+**: Provisioning de infraestructura AWS
- **18 recursos AWS**: Lambda, DynamoDB, API Gateway, CloudWatch, SNS, IAM

### Seguridad
- **Checkov 3.x**: Análisis estático de seguridad para IaC
- **IAM Policies**: Principio de menor privilegio
- **Encryption**: Datos cifrados en reposo (DynamoDB, Lambda)

### Observabilidad
- **Grafana 10.2**: Visualización de métricas y logs
- **Prometheus 2.47**: Recolección y almacenamiento de métricas
- **Loki 2.9**: Agregación de logs
- **Promtail 2.9**: Recolector de logs

### CI/CD
- **Jenkins LTS**: Servidor de automatización
- **JCasC**: Configuration as Code para Jenkins
- **Docker Agents**: Ejecución aislada de jobs
- **Pipelines**: Deployment automatizado

### Cloud (AWS)
- **Lambda**: Compute serverless (Python 3.11)
- **DynamoDB**: Base de datos NoSQL
- **API Gateway**: HTTP API v2
- **CloudWatch**: Logs, métricas, alarmas
- **SNS**: Notificaciones
- **IAM**: Gestión de identidad y acceso

---

## Inicio Rápido

### Prerequisitos

- Docker Desktop
- Terraform 1.6+
- Python 3.8+
- AWS CLI configurado
- Git

### Setup Inicial

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/dinex-tracking.git
cd dinex-tracking

# 2. Ejecutar setup automático
bash scripts/setup.sh

# 3. Configurar credenciales AWS
aws configure
```

### Uso con Makefile-DevOps

```bash
# Ver todos los comandos disponibles
make -f Makefile-DevOps help

# Setup completo del proyecto
make -f Makefile-DevOps setup

# Análisis de seguridad
make -f Makefile-DevOps security

# Levantar stack de monitoreo
make -f Makefile-DevOps monitor-up

# Construir y ejecutar Jenkins
make -f Makefile-DevOps jenkins-build
make -f Makefile-DevOps jenkins-run

# Empaquetar Lambda functions
make -f Makefile-DevOps lambda-package

# Deployment completo (seguridad + package + terraform)
make -f Makefile-DevOps deploy-all
```

---

## Componentes del Proyecto

### 1. Análisis de Seguridad con Checkov

**Ubicación:** `infrastructure/security/checkov/`

**Ejecutar análisis:**
```bash
cd infrastructure/security/checkov
bash run-checkov.sh
```

**Resultados:**
- Archivo XML: `infrastructure/security/results/checkov-results.xml`
- Archivo JSON: `infrastructure/security/results/checkov-results.json`

**Visualizar resultados:**
1. Abre https://lotterfriends.github.io/online-junit-parser/
2. Arrastra el archivo `checkov-results.xml`

**Configuración:**
- Archivo `.checkov.yml` con skips justificados para ambiente universitario
- Checks deshabilitados: Lambda DLQ, S3 logging, VPC (no aplican)
- Nivel de severidad: LOW (informativo)

---

### 2. Stack de Monitoreo (Grafana + Prometheus + Loki)

**Levantar servicios:**
```bash
docker-compose up -d
```

**Acceso a servicios:**
- **Grafana**: http://localhost:3000
  - Usuario: `admin`
  - Password: `admin123`

- **Prometheus**: http://localhost:9090

- **Loki**: http://localhost:3100

**Configuración:**
- Datasources provisioned automáticamente
- Dashboards incluidos
- Retention: 7 días (configurable)

**Detener servicios:**
```bash
docker-compose down
```

---

### 3. Jenkins CI/CD

**Construir imagen:**
```bash
cd jenkins
docker build -t dinex-tracking-jenkins .
```

**Ejecutar Jenkins:**
```bash
docker run -d \
  --name dinex-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  dinex-tracking-jenkins
```

**Acceso:**
- URL: http://localhost:8080
- Usuario: `admin` / Password: `admin123`
- Usuario estudiante: `estudiante` / Password: `dinex2024`

**Jobs predefinidos:**
1. `dinex-tracking-pipeline`: Pipeline principal
2. `security-scan-checkov`: Análisis de seguridad
3. `terraform-plan`: Validación de Terraform

**Características:**
- Configuration as Code (JCasC)
- Docker agents para aislamiento
- Plugins preinstalados
- Prometheus metrics exportados

---

### 4. Pipeline de Deployment

**Archivo:** `Jenkinsfile`

**Stages:**
1. **Checkout**: Obtener código del repositorio
2. **Security Check**: Ejecutar Checkov
3. **Terraform Validate**: Validar configuración
4. **Package Lambda**: Empaquetar funciones
5. **Run Tests**: Ejecutar tests unitarios
6. **Terraform Plan**: Generar plan
7. **Deploy to Dev**: Deployment a desarrollo (branch `develop`)
8. **Deploy to Production**: Deployment a producción (branch `main`)

**Ejecutar pipeline:**
- Push a branch `develop` → Deploy automático a Dev
- Push a branch `main` → Requiere aprobación manual para Prod

---

## Comandos Principales

### Análisis de Seguridad

```bash
# Ejecutar Checkov
make -f Makefile-DevOps security

# Ver resultados
cat infrastructure/security/results/checkov-results.json | jq
```

### Monitoreo

```bash
# Levantar stack completo
make -f Makefile-DevOps monitor-up

# Ver logs en tiempo real
make -f Makefile-DevOps monitor-logs

# Ver estado de servicios
make -f Makefile-DevOps monitor-status

# Detener servicios
make -f Makefile-DevOps monitor-down
```

### Jenkins

```bash
# Construir imagen
make -f Makefile-DevOps jenkins-build

# Iniciar Jenkins
make -f Makefile-DevOps jenkins-run

# Ver logs
make -f Makefile-DevOps jenkins-logs

# Detener Jenkins
make -f Makefile-DevOps jenkins-stop
```

### Terraform

```bash
# Inicializar
make -f Makefile-DevOps tf-init

# Validar
make -f Makefile-DevOps tf-validate

# Plan
make -f Makefile-DevOps tf-plan

# Aplicar
make -f Makefile-DevOps tf-apply

# Destruir
make -f Makefile-DevOps tf-destroy
```

### Lambda

```bash
# Empaquetar funciones
make -f Makefile-DevOps lambda-package

# Ejecutar tests
make -f Makefile-DevOps lambda-test
```

---

## Flujo de Trabajo Recomendado

### Para Desarrollo Local

```bash
# 1. Setup inicial (una vez)
bash scripts/setup.sh

# 2. Levantar servicios de monitoreo
make -f Makefile-DevOps monitor-up

# 3. Configurar Terraform
cd infrastructure/terraform
terraform init
terraform plan

# 4. Desarrollar y probar Lambda localmente
cd application/lambda/tracking
# ... hacer cambios ...
pytest ../tests/

# 5. Análisis de seguridad
make -f Makefile-DevOps security

# 6. Empaquetar y desplegar
make -f Makefile-DevOps deploy-all
```

### Para CI/CD con Jenkins

```bash
# 1. Construir Jenkins
make -f Makefile-DevOps jenkins-build

# 2. Ejecutar Jenkins
make -f Makefile-DevOps jenkins-run

# 3. Acceder a Jenkins (http://localhost:8080)
# 4. Configurar webhook de GitHub
# 5. Push código → Pipeline automático
```

---

## Estimación de Costos

### AWS (Free Tier)

| Servicio | Costo mensual | Límite Free Tier |
|----------|---------------|------------------|
| Lambda | $0 | 1M requests/mes |
| DynamoDB | $0 | 25 GB + 25 RCU/WCU |
| API Gateway | $3.50 | Después de 1M requests |
| CloudWatch | $2 | Después de 5 GB logs |
| SNS | $0 | 1M publicaciones |
| **TOTAL** | **$5-10/mes** | En desarrollo |

### Servicios Locales

| Servicio | Recursos | Costo |
|----------|----------|-------|
| Grafana | 512 MB RAM | $0 (local) |
| Prometheus | 1 GB RAM | $0 (local) |
| Loki | 512 MB RAM | $0 (local) |
| Jenkins | 2 GB RAM | $0 (local) |
| Checkov | Docker | $0 (local) |

---

## Justificación para Proyecto Individual

### Complejidad Apropiada

Este proyecto demuestra conocimientos en:

1. **Infrastructure as Code** (40%)
   - Terraform con 18 recursos AWS
   - Variables, outputs, módulos implícitos
   - State management

2. **Seguridad** (15%)
   - Análisis estático con Checkov
   - IAM roles y políticas
   - Encryption en reposo

3. **Observabilidad** (20%)
   - Stack completo Grafana + Prometheus + Loki
   - Dashboards personalizados
   - Métricas y logs centralizados

4. **CI/CD** (20%)
   - Jenkins con Configuration as Code
   - Pipelines automatizados
   - Docker agents

5. **Desarrollo** (5%)
   - Funciones Lambda en Python
   - Tests unitarios
   - Empaquetado automatizado

**Total:** Proyecto completo pero manejable para 1 persona en 3-4 semanas.

---

## Diferencias vs Proyecto de 5 Personas

| Aspecto | Proyecto 5 personas | Este proyecto (1 persona) |
|---------|---------------------|---------------------------|
| Lambdas | 5 funciones | 2 funciones |
| DynamoDB | 3-4 tablas | 1 tabla |
| Endpoints | 10+ | 4 |
| Módulos Terraform | 8-10 módulos separados | 1 archivo main.tf |
| Autenticación | Cognito completo | No incluida (simplificado) |
| Multi-región | Sí | No |
| VPC | Configuración compleja | No (Lambda sin VPC) |
| CI/CD | GitHub Actions + Jenkins + ArgoCD | Solo Jenkins básico |
| Monitoreo | Datadog/New Relic | Grafana stack (open source) |

---

## Para la Presentación

### Demostración (15 minutos)

1. **Checkov** (3 min)
   - Ejecutar análisis
   - Mostrar resultados en parser online
   - Explicar skips justificados

2. **Grafana** (4 min)
   - Mostrar dashboard
   - Explicar métricas de Lambda
   - Mostrar logs en Loki

3. **Jenkins** (4 min)
   - Mostrar JCasC configuration
   - Ejecutar pipeline
   - Mostrar agentes Docker

4. **Terraform + AWS** (4 min)
   - Mostrar main.tf
   - Ejecutar terraform plan
   - Mostrar recursos en AWS Console

### Preguntas Esperadas

**P: ¿Por qué no usaste módulos separados en Terraform?**
R: Para un proyecto individual, un archivo main.tf de ~600 líneas es más manejable y fácil de entender que módulos distribuidos. Mantiene toda la configuración visible y reduce complejidad innecesaria.

**P: ¿Por qué Jenkins y no GitHub Actions?**
R: Jenkins permite demostrar Configuration as Code (JCasC), gestión de agentes con Docker, y es más completo para proyectos empresariales. GitHub Actions es más simple pero menos configurable.

**P: ¿Checkov encontró errores?**
R: Sí, pero están justificados para ambiente de desarrollo universitario. Por ejemplo, omití Lambda DLQ porque no es crítico en desarrollo, y evité VPC para simplificar el proyecto.

**P: ¿Por qué Grafana y no CloudWatch nativo?**
R: Grafana demuestra conocimientos de observabilidad open-source, es más personalizable, y permite centralizar logs (Loki) y métricas (Prometheus) en una sola interfaz.

---

## Troubleshooting

### Checkov no ejecuta

```bash
# Verificar Docker
docker ps

# Dar permisos al script
chmod +x infrastructure/security/checkov/run-checkov.sh

# Ejecutar manualmente
cd infrastructure/security/checkov
bash run-checkov.sh
```

### Grafana no inicia

```bash
# Ver logs
docker-compose logs grafana

# Reiniciar servicios
docker-compose restart

# Verificar puertos
netstat -an | grep 3000
```

### Jenkins no accesible

```bash
# Ver logs
docker logs dinex-jenkins

# Verificar que está corriendo
docker ps | grep jenkins

# Reiniciar
docker restart dinex-jenkins
```

---

## Referencias

- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Checkov Documentation**: https://www.checkov.io/
- **Grafana Docs**: https://grafana.com/docs/grafana/latest/
- **Jenkins JCasC**: https://github.com/jenkinsci/configuration-as-code-plugin
- **AWS Lambda**: https://docs.aws.amazon.com/lambda/
- **Prometheus**: https://prometheus.io/docs/

---

## Autor

**Nombre:** [Tu Nombre]
**Universidad:** [Tu Universidad]
**Curso:** Infraestructura como Código
**Año:** 2025
**Email:** [tu-email@universidad.edu]

---

## Licencia

Este proyecto es para fines educativos únicamente.

---

**¡Proyecto completo con DevOps stack listo para demostración!** 🚀
