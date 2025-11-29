// Pipeline principal para DINEX Tracking
// Proyecto universitario individual

pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PROJECT = 'dinex-tracking'
        ENVIRONMENT = 'dev'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Obteniendo código del repositorio...'
                checkout scm
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    env.GIT_COMMIT_SHORT = readFile('.git/commit-id').trim()
                }
                echo "✅ Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }

        stage('Security Check - Checkov') {
            agent {
                label 'docker-agent'
            }
            steps {
                echo '🔍 Ejecutando análisis de seguridad con Checkov...'
                sh '''
                    cd infrastructure/security/checkov
                    chmod +x run-checkov.sh
                    ./run-checkov.sh || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'infrastructure/security/results/*.xml', allowEmptyArchive: true
                    junit testResults: 'infrastructure/security/results/*.xml', allowEmptyResults: true
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo '📋 Validando configuración de Terraform...'
                dir('infrastructure/terraform') {
                    sh '''
                        terraform init -backend=false
                        terraform fmt -check || true
                        terraform validate
                    '''
                }
                echo '✅ Terraform validado correctamente'
            }
        }

        stage('Package Lambda Functions') {
            steps {
                echo '📦 Empaquetando funciones Lambda...'
                sh '''
                    # Función tracking
                    cd application/lambda/tracking
                    if [ -f deployment.zip ]; then rm deployment.zip; fi
                    zip -r deployment.zip index.py
                    ls -lh deployment.zip

                    # Función notifications
                    cd ../notifications
                    if [ -f deployment.zip ]; then rm deployment.zip; fi
                    zip -r deployment.zip index.py
                    ls -lh deployment.zip
                '''
                echo '✅ Funciones Lambda empaquetadas'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'application/lambda/**/deployment.zip', allowEmptyArchive: false
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Ejecutando tests...'
                sh '''
                    cd application
                    python3 -m pytest tests/ --junit-xml=test-results.xml -v || true
                '''
            }
            post {
                always {
                    junit testResults: 'application/test-results.xml', allowEmptyResults: true
                }
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
                echo '📊 Generando plan de Terraform...'
                dir('infrastructure/terraform') {
                    sh '''
                        terraform init
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo '🚀 Desplegando a ambiente Dev...'
                input message: '¿Desplegar a Dev?', ok: 'Desplegar'
                dir('infrastructure/terraform') {
                    sh '''
                        terraform apply tfplan -auto-approve
                    '''
                }
                echo '✅ Deployment a Dev completado'
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Desplegando a Producción...'
                input message: '⚠️ ¿Confirmar deployment a PRODUCCIÓN?', ok: 'DESPLEGAR'
                dir('infrastructure/terraform') {
                    sh '''
                        terraform apply tfplan -auto-approve
                    '''
                }
                echo '✅ Deployment a Producción completado'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline ejecutado exitosamente'
        }
        failure {
            echo '❌ Pipeline falló. Revisar logs para más detalles.'
        }
        always {
            echo '🧹 Limpiando workspace...'
            cleanWs()
        }
    }
}
