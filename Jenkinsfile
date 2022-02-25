pipeline {
    agent any
    stages {
        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'SonarQube') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        stage('Building Artifacts') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}