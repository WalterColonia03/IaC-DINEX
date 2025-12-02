// Pipeline CI/CD - Sistema de Tracking DINEX

pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PROJECT = 'dinex-tracking'
        ENVIRONMENT = 'dev'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Obteniendo código del repositorio'
                checkout scm
            }
        }

        stage('Security Check') {
            steps {
                echo 'Ejecutando análisis de seguridad con Checkov'
                script {
                    sh '''
                        cd infrastructure/security/checkov
                        chmod +x run-checkov.sh
                        ./run-checkov.sh || true
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo 'Validando configuración de Terraform'
                dir('infrastructure/terraform') {
                    sh 'terraform init -backend=false'
                    sh 'terraform fmt -check || true'
                    sh 'terraform validate'
                }
            }
        }

        stage('Package Lambda') {
            steps {
                echo 'Empaquetando función Lambda'
                sh '''
                    cd application/lambda/tracking
                    if [ -f deployment.zip ]; then rm deployment.zip; fi
                    zip -r deployment.zip index.py
                    ls -lh deployment.zip
                '''
            }
        }

        stage('Terraform Plan') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                echo 'Generando plan de cambios'
                dir('infrastructure/terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform show tfplan'
                }
            }
        }

        stage('Approve Deployment') {
            when {
                branch 'main'
            }
            steps {
                echo 'Requiere aprobación manual'
                input message: 'Desplegar a producción?', ok: 'Desplegar'
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                echo 'Desplegando infraestructura'
                dir('infrastructure/terraform') {
                    sh 'terraform apply tfplan -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completado exitosamente'
        }
        failure {
            echo 'Pipeline falló - revisar logs'
        }
        always {
            echo 'Limpiando workspace'
            cleanWs()
        }
    }
}
