# ⚡ Comandos Rápidos - DINEX Tracking DevOps

Cheat sheet con todos los comandos importantes del proyecto.

---

## 🚀 INICIO RÁPIDO (Copy & Paste)

```bash
# 1. Setup inicial completo
bash scripts/setup.sh

# 2. Levantar monitoreo
docker-compose up -d

# 3. Ver servicios
docker-compose ps

# 4. Acceder a servicios
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9090
# Loki: http://localhost:3100
```

---

## 📋 MAKEFILE DEVOPS

### Ver comandos disponibles
```bash
make -f Makefile-DevOps help
```

### Setup y configuración
```bash
make -f Makefile-DevOps setup
make -f Makefile-DevOps status
make -f Makefile-DevOps urls
```

### Seguridad (Checkov)
```bash
make -f Makefile-DevOps security
```

### Monitoreo
```bash
make -f Makefile-DevOps monitor-up
make -f Makefile-DevOps monitor-down
make -f Makefile-DevOps monitor-logs
make -f Makefile-DevOps monitor-status
make -f Makefile-DevOps monitor-restart
```

### Jenkins
```bash
make -f Makefile-DevOps jenkins-build
make -f Makefile-DevOps jenkins-run
make -f Makefile-DevOps jenkins-stop
make -f Makefile-DevOps jenkins-logs
make -f Makefile-DevOps jenkins-restart
```

### Terraform
```bash
make -f Makefile-DevOps tf-init
make -f Makefile-DevOps tf-validate
make -f Makefile-DevOps tf-plan
make -f Makefile-DevOps tf-apply
make -f Makefile-DevOps tf-destroy
```

### Lambda
```bash
make -f Makefile-DevOps lambda-package
make -f Makefile-DevOps lambda-test
```

### Deployment
```bash
make -f Makefile-DevOps deploy-all
```

### Limpieza
```bash
make -f Makefile-DevOps clean
make -f Makefile-DevOps clean-all
```

---

## 🔍 CHECKOV

### Ejecutar análisis
```bash
cd infrastructure/security/checkov
bash run-checkov.sh
```

### Ver resultados JSON
```bash
cat infrastructure/security/results/checkov-results.json | jq
```

### Ver resultados online
```bash
# 1. Abrir https://lotterfriends.github.io/online-junit-parser/
# 2. Arrastrar: infrastructure/security/results/checkov-results.xml
```

---

## 📊 GRAFANA + PROMETHEUS + LOKI

### Levantar stack
```bash
docker-compose up -d
```

### Ver logs de todos los servicios
```bash
docker-compose logs -f
```

### Ver logs de un servicio específico
```bash
docker-compose logs -f grafana
docker-compose logs -f prometheus
docker-compose logs -f loki
docker-compose logs -f promtail
```

### Reiniciar servicios
```bash
docker-compose restart
docker-compose restart grafana
```

### Detener servicios
```bash
docker-compose down
```

### Detener y limpiar volúmenes
```bash
docker-compose down -v
```

### Ver estado
```bash
docker-compose ps
```

### Acceso a servicios
```bash
# Grafana
open http://localhost:3000
# Usuario: admin
# Password: admin123

# Prometheus
open http://localhost:9090

# Loki
open http://localhost:3100
```

---

## 🔧 JENKINS

### Construir imagen
```bash
cd jenkins
docker build -t dinex-tracking-jenkins .
```

### Ejecutar Jenkins
```bash
docker run -d \
  --name dinex-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  dinex-tracking-jenkins
```

### Windows (Git Bash o WSL)
```bash
docker run -d \
  --name dinex-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v //var/run/docker.sock:/var/run/docker.sock \
  dinex-tracking-jenkins
```

### Ver logs
```bash
docker logs -f dinex-jenkins
```

### Detener Jenkins
```bash
docker stop dinex-jenkins
docker rm dinex-jenkins
```

### Reiniciar Jenkins
```bash
docker restart dinex-jenkins
```

### Acceso
```bash
open http://localhost:8080
# Usuario: admin / Password: admin123
# O: estudiante / Password: dinex2024
```

---

## 🏗️ TERRAFORM

### Navegar al directorio
```bash
cd infrastructure/terraform
```

### Inicializar
```bash
terraform init
```

### Formatear código
```bash
terraform fmt
terraform fmt -recursive
```

### Validar sintaxis
```bash
terraform validate
```

### Ver plan
```bash
terraform plan
```

### Ver plan detallado
```bash
terraform plan -out=tfplan
terraform show tfplan
```

### Aplicar cambios
```bash
terraform apply
```

### Aplicar sin confirmación
```bash
terraform apply -auto-approve
```

### Ver outputs
```bash
terraform output
terraform output api_endpoint
terraform output -raw api_endpoint
```

### Destruir infraestructura
```bash
terraform destroy
```

### Importar recurso existente
```bash
terraform import aws_lambda_function.tracking dinex-tracking-dev
```

### Ver estado
```bash
terraform state list
terraform state show aws_lambda_function.tracking
```

---

## 📦 LAMBDA

### Empaquetar función tracking
```bash
cd application/lambda/tracking
zip -r deployment.zip index.py
```

### Windows (PowerShell)
```powershell
cd application/lambda/tracking
Compress-Archive -Path index.py -DestinationPath deployment.zip -Force
```

### Empaquetar función notifications
```bash
cd application/lambda/notifications
zip -r deployment.zip index.py
```

### Verificar tamaño
```bash
ls -lh application/lambda/*/deployment.zip
```

---

## 🧪 TESTS

### Ejecutar todos los tests
```bash
cd application
python3 -m pytest tests/ -v
```

### Con cobertura
```bash
python3 -m pytest tests/ --cov=lambda --cov-report=html
```

### Ver reporte de cobertura
```bash
open htmlcov/index.html
```

---

## 🐳 DOCKER

### Ver contenedores corriendo
```bash
docker ps
```

### Ver todos los contenedores
```bash
docker ps -a
```

### Ver logs de un contenedor
```bash
docker logs dinex-grafana
docker logs -f dinex-grafana  # Seguir logs
```

### Entrar a un contenedor
```bash
docker exec -it dinex-grafana /bin/sh
docker exec -it dinex-prometheus /bin/sh
```

### Ver uso de recursos
```bash
docker stats
```

### Limpiar contenedores detenidos
```bash
docker container prune
```

### Limpiar imágenes no usadas
```bash
docker image prune -a
```

### Limpiar volúmenes
```bash
docker volume prune
```

### Limpiar todo
```bash
docker system prune -a --volumes
```

---

## 🔑 AWS CLI

### Configurar credenciales
```bash
aws configure
```

### Verificar identidad
```bash
aws sts get-caller-identity
```

### Listar funciones Lambda
```bash
aws lambda list-functions --region us-east-1
```

### Ver logs de Lambda
```bash
aws logs tail /aws/lambda/dinex-tracking-dev --follow
```

### Listar tablas DynamoDB
```bash
aws dynamodb list-tables --region us-east-1
```

### Ver items en DynamoDB
```bash
aws dynamodb scan --table-name dinex-tracking-dev
```

### Invocar Lambda
```bash
aws lambda invoke \
  --function-name dinex-tracking-dev \
  --payload '{"httpMethod":"GET","path":"/health"}' \
  response.json
```

---

## 📝 GIT

### Ver estado
```bash
git status
```

### Agregar archivos
```bash
git add .
git add infrastructure/
```

### Commit
```bash
git commit -m "feat: add DevOps stack (Checkov, Grafana, Jenkins)"
```

### Push
```bash
git push origin main
```

### Ver ramas
```bash
git branch
git branch -a
```

### Crear rama
```bash
git checkout -b feature/add-devops
```

### Ver historial
```bash
git log --oneline --graph
```

---

## 🔍 DEBUGGING

### Ver puertos en uso
```bash
# Linux/Mac
netstat -tulpn | grep LISTEN
lsof -i :3000

# Windows
netstat -an | findstr LISTENING
```

### Verificar Docker está corriendo
```bash
docker info
docker version
```

### Verificar Terraform instalado
```bash
terraform version
```

### Verificar AWS CLI configurado
```bash
aws configure list
```

### Verificar Python y pip
```bash
python3 --version
pip3 --version
```

### Ver variables de entorno
```bash
env | grep AWS
```

---

## 🧹 LIMPIEZA COMPLETA

### Detener todos los servicios
```bash
# Detener Docker Compose
docker-compose down -v

# Detener Jenkins
docker stop dinex-jenkins
docker rm dinex-jenkins

# Limpiar Docker
docker system prune -a --volumes

# Limpiar Terraform
cd infrastructure/terraform
rm -rf .terraform
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl

# Limpiar Lambda packages
rm -f application/lambda/*/deployment.zip

# Limpiar resultados Checkov
rm -f infrastructure/security/results/*
```

---

## 📊 VERIFICACIÓN COMPLETA

### Checklist de servicios funcionando

```bash
# 1. Docker
docker ps
# Debe mostrar: grafana, prometheus, loki, promtail

# 2. Grafana
curl -s http://localhost:3000/api/health | jq
# Debe retornar: {"database":"ok"}

# 3. Prometheus
curl -s http://localhost:9090/-/healthy
# Debe retornar: Prometheus is Healthy.

# 4. Loki
curl -s http://localhost:3100/ready
# Debe retornar: ready

# 5. Jenkins (si está corriendo)
curl -s http://localhost:8080/login
# Debe retornar HTML con "Jenkins"

# 6. Terraform
cd infrastructure/terraform
terraform validate
# Debe retornar: Success! The configuration is valid.

# 7. Lambda packages
ls -lh application/lambda/*/deployment.zip
# Debe mostrar ambos archivos .zip
```

---

## 🚨 SOLUCIÓN DE PROBLEMAS COMUNES

### Error: "Address already in use"
```bash
# Ver qué proceso usa el puerto
lsof -i :3000
lsof -i :8080

# Matar proceso
kill -9 <PID>

# O cambiar puerto en docker-compose.yml
```

### Error: "Cannot connect to Docker daemon"
```bash
# Verificar Docker está corriendo
docker info

# Reiniciar Docker Desktop
# (Cerrar y abrir la aplicación)
```

### Error: Terraform "No valid credential sources"
```bash
# Configurar AWS CLI
aws configure

# Verificar credenciales
aws sts get-caller-identity
```

### Grafana no muestra datos
```bash
# Verificar datasources
curl http://localhost:3000/api/datasources

# Reiniciar Grafana
docker-compose restart grafana
```

### Jenkins no accesible
```bash
# Ver logs
docker logs dinex-jenkins

# Verificar está corriendo
docker ps | grep jenkins

# Reiniciar
docker restart dinex-jenkins
```

---

## 📖 DOCUMENTACIÓN

### Ver documentación completa
```bash
cat README-DEVOPS.md
cat STACK-DEVOPS-COMPLETADO.md
cat GUIA_CONFIGURACION_AWS.md
cat EXPLICACION_PASO_A_PASO.md
```

### Ver ayuda de comandos
```bash
make -f Makefile-DevOps help
terraform --help
docker-compose --help
aws help
```

---

## 🎯 COMANDOS PARA DEMO/PRESENTACIÓN

### Secuencia recomendada para demostración

```bash
# 1. Mostrar estructura del proyecto
tree -L 2

# 2. Levantar monitoreo
make -f Makefile-DevOps monitor-up
make -f Makefile-DevOps monitor-status

# 3. Abrir Grafana en navegador
open http://localhost:3000

# 4. Ejecutar análisis de seguridad
make -f Makefile-DevOps security

# 5. Ver resultados Checkov
cat infrastructure/security/results/checkov-results.json | jq '.summary'

# 6. Iniciar Jenkins
make -f Makefile-DevOps jenkins-run

# 7. Abrir Jenkins
open http://localhost:8080

# 8. Validar Terraform
cd infrastructure/terraform
terraform init
terraform validate
terraform plan

# 9. Mostrar Lambda functions
cat application/lambda/tracking/index.py

# 10. Ver todos los servicios
make -f Makefile-DevOps status
make -f Makefile-DevOps urls
```

---

**¡Guarda este archivo como referencia rápida!** 📌
