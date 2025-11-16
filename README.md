# Documentación de la Automatización de Integración Continua para 5etools

## Introducción

Este ejercicio ha sido toda una **tortura** y he tenido que ir adaptándome a las condiciones que se presentaban. Debido a las interminables dificultades de usar réplicas con Kubernetes, he optado por realizar la automatización utilizando **Docker**. Estoy muy descontento con la basura de trabajo que he hecho. Además no puedo poner imagenes porque he desistalado docker y todas sus dependencias y ahora no consigo instalarlo porque tengo los repositorios de mi Arch Linux rotos como mi corazón y cabeza.  

Lo único que he conseguido ha sido automatizar el despliegue cada vez que se realizan modificaciones en el repositorio. Pero da igual porque el trabajo que he hecho lo hace hasta un niño de 5 años y como no puedo mostrar como estaba funcionando da es aún más penoso lo que he hecho porque soy gilipollas. A continuación, se detalla el procedimiento seguido y los retos superados.

---

## 1. Repositorio

Para empezar, he llevado el repositorio de 5etools a un **repositorio público**:

- Original: [5etools-src](https://github.com/5etools-mirror-3/5etools-src?tab=readme-ov-file)
- Modificado: [5etools_InakiSpinardi](https://github.com/ikdxz/5etools_InakiSpinardi.git)

El **Dockerfile original** era demasiado pesado (más de 6GB de descarga), por lo que he creado uno nuevo desde cero:

```dockerfile
FROM node:17-alpine
WORKDIR /app
COPY . .
RUN npm install -g http-server
CMD ["http-server", "-p", "5050", "-a", "0.0.0.0"]
EXPOSE 5050
```
## 2. Configuración de Jenkins

Para automatizar el despliegue, se construye una imagen de Jenkins con Docker y acceso al socket de Docker:

docker build -t inaki/jenkins:latest .
docker compose up


Jenkins se expone en el puerto 9000.

Tras la instalación inicial, se crea un Pipeline que apunta al repositorio modificado.

La ruta del Jenkinsfile se encuentra en jenkins/Jenkinsfile.

## 3. Pipeline de Jenkins

El pipeline realiza los siguientes pasos:

Clonar el repositorio si no está presente.

Acceder al directorio 5etools-src.

Construir la imagen del Dockerfile.

Levantar el servidor local en el puerto 5050.

El pipeline está configurado para activarse cada vez que se modifica el repositorio, mediante un hook de GitHub.

## 4. Automatización con Hooks

Para que Jenkins se dispare automáticamente al hacer un commit, se utiliza un hook local:
```
#!/bin/sh

# Usuario de Jenkins y su token
JENKINS_USER="inaki"
JENKINS_TOKEN="1146d7a47af99c0273106cbe871c74e55a"

# URL de Jenkins para tu job
JENKINS_URL="http://localhost:9000/job/5etools/build"

# Obtener crumb de Jenkins (para CSRF)
CRUMB=$(curl -s -u $JENKINS_USER:$JENKINS_TOKEN "$JENKINS_URL/../crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

# Disparar Jenkins
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -u $JENKINS_USER:$JENKINS_TOKEN -H "$CRUMB" "$JENKINS_URL")

# Confirmación
if [ "$RESPONSE" -eq 201 ]; then
    echo "✅ Jenkins disparado correctamente."
else
    echo "❌ Error al disparar Jenkins. Código HTTP: $RESPONSE"
fi
```

Este script debe estar ubicado en .git/hooks con un nombre como post-commit.

Para uso global, la solución sería más compleja, incluyendo un proxy que reciba la petición de GitHub, obtenga el crumb y mande la petición a Jenkins.

## 5. Resultados

Servidor en localhost:5050 funcionando.

Automatización activada con Docker y Jenkins.

Cada vez que se hace un commit, Jenkins reconstruye la imagen y reinicia el contenedor automáticamente.

Kubernetes no se ha usado directamente debido a las dificultades encontradas con las réplicas, pero el proceso simula la recuperación automática y balanceo de carga mediante Docker.
