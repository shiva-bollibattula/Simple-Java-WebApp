pipeline {
    agent any
    stages {
        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'SonarQube') {
                        sh 'mvn sonar:sonar'
                    }
                    timeout(time:1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if(qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Checking for Vulnerabilities') {
            steps {
                dependencycheck additionalArguments: '--scan ./', odcInstallation: 'Dependency Checker'
                dependencyCheckPublisher()
            }
        }
        stage('Building Artifacts') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Building Image') {
            steps {
                sh 'docker image build -t WebApp .'
            }
        }
    }
    post {
        always {
            dependencyCheckPublisher()
        }
    }
}