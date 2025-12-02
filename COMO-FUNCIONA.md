# Sistema de Tracking DINEX - Funcionamiento

## Resumen del Proyecto

Sistema serverless de tracking de paquetes desplegado en AWS usando Infrastructure as Code (Terraform) con pipeline de CI/CD automatizado.

---

## Arquitectura

```
Usuario HTTP Request
        ↓
   API Gateway (HTTP API)
        ↓
   Lambda (Python 3.11)
        ↓
   DynamoDB (NoSQL)
        ↓
   SNS (Notificaciones)
```

---

## Tecnologías Principales

### Infraestructura (AWS)
- **Lambda**: Ejecución de código serverless sin administrar servidores
- **DynamoDB**: Base de datos NoSQL con modelo PAY_PER_REQUEST
- **API Gateway**: Punto de entrada HTTP para el sistema
- **SNS**: Sistema de notificaciones pub/sub
- **CloudWatch**: Logs y alarmas de monitoreo

### Infrastructure as Code
- **Terraform**: Provisiona toda la infraestructura AWS
- **HCL**: Lenguaje declarativo de Terraform

### CI/CD
- **Jenkins**: Servidor de automatización para pipeline
- **Checkov**: Análisis de seguridad de código Terraform
- **Docker**: Contenerización de Jenkins y herramientas

### Monitoreo (Opcional)
- **Grafana**: Visualización de métricas
- **Prometheus**: Recolección de métricas
- **Loki**: Agregación de logs

---

## Flujo Completo del Sistema

### 1. Desarrollo Local

```bash
# Editar código Terraform o Python
infrastructure/terraform/main.tf
application/lambda/tracking/index.py

# Validar localmente
cd infrastructure/terraform
terraform validate
terraform plan
```

### 2. Pipeline CI/CD (Automático)

```
Git Push → GitHub
     ↓
Jenkins detecta cambio
     ↓
Stage 1: Checkout
   - Clona el repositorio
     ↓
Stage 2: Security Check
   - Ejecuta Checkov en Terraform
   - Detecta vulnerabilidades de seguridad
     ↓
Stage 3: Terraform Validate
   - terraform init
   - terraform fmt -check
   - terraform validate
     ↓
Stage 4: Package Lambda
   - Crea deployment.zip con index.py
     ↓
Stage 5: Terraform Plan
   - Genera plan de cambios
   - Muestra qué recursos se crearán/modificarán
     ↓
Stage 6: Approval (solo main branch)
   - Espera aprobación manual
     ↓
Stage 7: Deploy
   - terraform apply
   - Crea/actualiza infraestructura en AWS
```

### 3. Infraestructura AWS (Creada por Terraform)

**Terraform crea en orden:**

```
1. DynamoDB Table
   - Nombre: dinex-tracking-dev
   - Partition Key: tracking_id
   - TTL habilitado (30 días)
   - Cifrado en reposo

2. IAM Role
   - Para Lambda ejecutar con permisos

3. IAM Policy
   - Permisos para DynamoDB (Get, Put, Query)
   - Permisos para CloudWatch Logs
   - Permisos para SNS

4. Lambda Function
   - Runtime: Python 3.11
   - Handler: index.handler
   - Memory: 256 MB
   - Timeout: 10 segundos
   - Variables de entorno: TABLE_NAME, SNS_TOPIC

5. CloudWatch Log Group
   - Retención: 7 días
   - Para logs de Lambda

6. API Gateway HTTP API
   - CORS configurado
   - Throttling: 100 req/s

7. API Gateway Stage
   - Nombre: dev
   - Auto-deploy habilitado
   - Logs de acceso

8. API Gateway Integration
   - Conecta API Gateway con Lambda

9. API Routes
   - GET /health
   - GET /tracking
   - POST /tracking

10. Lambda Permission
    - Permite a API Gateway invocar Lambda

11. SNS Topic
    - Para notificaciones

12. CloudWatch Alarm
    - Alerta si Lambda tiene >5 errores
```

### 4. Uso en Producción

**Request del Usuario:**

```
Cliente → GET https://api.dinex.com/dev/tracking?tracking_id=TRK001
```

**Flujo Interno:**

```
1. API Gateway recibe request
2. API Gateway valida routing
3. API Gateway invoca Lambda
4. Lambda handler() procesa:
   a. Parsea evento HTTP
   b. Extrae tracking_id
   c. Query a DynamoDB
   d. Retorna respuesta JSON
5. API Gateway devuelve respuesta al cliente
```

**Request POST:**

```
Cliente → POST https://api.dinex.com/dev/tracking
Body: {"tracking_id":"TRK001","location":"Lima","status":"IN_TRANSIT"}
```

**Flujo Interno:**

```
1. API Gateway recibe POST
2. Lambda recibe body JSON
3. Lambda valida datos
4. Lambda escribe en DynamoDB
5. Lambda publica a SNS
6. SNS notifica suscriptores
7. Lambda retorna confirmación
```

---

## Estructura de Archivos

```
project/
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf          # Definición de recursos AWS
│   │   ├── variables.tf     # Variables configurables
│   │   └── outputs.tf       # Valores de salida
│   └── security/
│       └── checkov/
│           └── run-checkov.sh
│
├── application/
│   └── lambda/
│       └── tracking/
│           └── index.py     # Código Lambda
│
├── jenkins/
│   ├── Dockerfile           # Imagen custom Jenkins
│   └── casc.yaml           # Configuration as Code
│
├── monitoring/              # Stack de monitoreo
│   ├── grafana/
│   ├── prometheus/
│   ├── loki/
│   └── promtail/
│
├── Jenkinsfile             # Pipeline CI/CD
└── docker-compose.yml      # Stack de monitoreo
```

---

## Código Lambda Simplificado

```python
def handler(event, context):
    """Entry point de Lambda"""
    method = event['requestContext']['http']['method']
    path = event['requestContext']['http']['path']

    if path.endswith('/health'):
        return health_check()
    elif method == 'GET':
        return get_tracking(event)
    elif method == 'POST':
        return update_tracking(event)
```

**GET:** Lee de DynamoDB y retorna JSON
**POST:** Valida, escribe en DynamoDB, publica a SNS

---

## Terraform Simplificado

```hcl
# Define qué recursos crear
resource "aws_dynamodb_table" "tracking" {
  name         = "dinex-tracking-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tracking_id"
}

resource "aws_lambda_function" "tracking" {
  function_name = "dinex-tracking-dev"
  runtime       = "python3.11"
  handler       = "index.handler"
  filename      = "deployment.zip"
}
```

**Terraform traduce esto a llamadas API de AWS**

---

## Costos

**Con Free Tier:**
- Lambda: 1M requests gratis/mes → $0
- DynamoDB: 25 GB gratis → $0
- API Gateway: 1M requests gratis/mes → $0
- Total: $0-2/mes

**Sin Free Tier (estimado para 1000 requests/mes):**
- Lambda: ~$0.01
- DynamoDB: ~$0.25
- API Gateway: ~$0.01
- Total: ~$0.30/mes

---

## Seguridad

1. **IAM**: Permisos mínimos necesarios
2. **Checkov**: Análisis estático de seguridad
3. **Cifrado**: DynamoDB encrypted at rest
4. **TTL**: Auto-eliminación de datos antiguos
5. **CloudWatch Alarms**: Alertas de errores

---

## Ventajas de esta Arquitectura

1. **Serverless**: No administrar servidores
2. **Escalable**: AWS escala automáticamente
3. **Económico**: Pago solo por uso
4. **Automatizado**: Pipeline CI/CD completo
5. **Seguro**: Múltiples capas de seguridad
6. **Versionado**: Infraestructura en Git

---

## Comandos Clave

```bash
# Validar Terraform
terraform validate

# Ver plan de cambios
terraform plan

# Aplicar cambios
terraform apply

# Empaquetar Lambda
cd application/lambda/tracking
zip -r deployment.zip index.py

# Ejecutar Checkov
./infrastructure/security/checkov/run-checkov.sh

# Levantar monitoreo
docker-compose up -d
```

---

## Limitaciones Actuales

- Solo ambiente dev (no staging/prod)
- Single región (us-east-1)
- Sin tests automatizados
- Sin autenticación en API
- Sin rate limiting por usuario

Estas son mejoras futuras identificadas en TODOs del código.
