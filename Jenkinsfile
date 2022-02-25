pipeline {
    agent any
    stages {
        stage('Building Artifacts') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}