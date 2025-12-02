# Comandos Rápidos - SonarQube

## Setup Inicial (Una sola vez)

### 1. Instalar dependencias de Node.js

```bash
npm install
```

Este comando instala `sonarqube-scanner` necesario para el análisis.

---

### 2. Levantar servidor SonarQube

```bash
docker-compose -f docker-compose.sonar.yml up -d
```

Espera 2-3 minutos para que el servidor inicie completamente.

**Verificar:**
```bash
docker-compose -f docker-compose.sonar.yml ps
```

Deberías ver:
```
NAME                     STATUS
dinex-sonarqube          Up
dinex-sonarqube-db       Up
```

---

### 3. Configurar token (Primera vez)

**Paso A: Acceder a SonarQube**
- URL: http://localhost:9000
- Usuario: `admin`
- Password: `admin`
- Te pedirá cambiar la contraseña (usa algo seguro)

**Paso B: Generar token**
1. Ve a: My Account (icono usuario arriba derecha)
2. Haz clic en "Security"
3. En "Generate Tokens":
   - Name: `dinex-tracking`
   - Type: `Global Analysis Token`
   - Expires in: `No expiration`
4. Haz clic en "Generate"
5. COPIA EL TOKEN (solo se muestra una vez)

**Paso C: Configurar token en tu sistema**

**Windows (PowerShell):**
```powershell
$env:SONAR_TOKEN="tu-token-copiado-aqui"
```

**Linux/Mac:**
```bash
export SONAR_TOKEN="tu-token-copiado-aqui"
```

**O crear archivo .env:**
```bash
echo "SONAR_TOKEN=tu-token-copiado-aqui" > .env
```

---

## Uso Diario

### Ejecutar análisis de código

```bash
npm run sonar
```

O con el token directamente:

**Windows (PowerShell):**
```powershell
npx sonar-scanner -Dsonar.login=$env:SONAR_TOKEN
```

**Linux/Mac:**
```bash
npx sonar-scanner -Dsonar.login=$SONAR_TOKEN
```

---

### Ver resultados

Abre en navegador: http://localhost:9000

Haz clic en el proyecto "dinex-tracking"

---

## Comandos de Gestión

### Ver logs de SonarQube

```bash
docker-compose -f docker-compose.sonar.yml logs -f
```

### Detener SonarQube

```bash
docker-compose -f docker-compose.sonar.yml down
```

### Iniciar SonarQube (después de detener)

```bash
docker-compose -f docker-compose.sonar.yml up -d
```

### Reiniciar SonarQube

```bash
docker-compose -f docker-compose.sonar.yml restart
```

### Eliminar todo (datos incluidos)

```bash
docker-compose -f docker-compose.sonar.yml down -v
```

---

## Troubleshooting

### SonarQube no inicia

```bash
# Ver errores
docker-compose -f docker-compose.sonar.yml logs sonarqube

# Verificar puertos
netstat -ano | findstr :9000
```

### Error de memoria

Aumenta memoria de Docker Desktop:
- Settings > Resources > Memory: 4GB mínimo

### Puerto 9000 ocupado

Edita `docker-compose.sonar.yml` y cambia:
```yaml
ports:
  - "9001:9000"
```

Luego accede a http://localhost:9001

---

## Workflow Completo

```bash
# 1. Primera vez: Instalar
npm install

# 2. Primera vez: Levantar SonarQube
docker-compose -f docker-compose.sonar.yml up -d

# 3. Primera vez: Configurar token
# Acceder a http://localhost:9000 y seguir pasos

# 4. Ejecutar análisis
npm run sonar

# 5. Ver resultados
# Abrir http://localhost:9000

# 6. Al terminar (opcional)
docker-compose -f docker-compose.sonar.yml down
```

---

## Integración con Makefile

Puedes agregar a tu Makefile:

```makefile
sonar-up:
	docker-compose -f docker-compose.sonar.yml up -d

sonar-down:
	docker-compose -f docker-compose.sonar.yml down

sonar-scan:
	npm run sonar

sonar-logs:
	docker-compose -f docker-compose.sonar.yml logs -f
```

Uso:
```bash
make sonar-up
make sonar-scan
make sonar-down
```
