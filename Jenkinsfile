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
                dependencyCheck additionalArguments: '--scan .', odcInstallation: 'Dependency Checker'
            }
        }
        stage('Building Artifacts') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Pushing Artifacts'){
            steps {
                nexusArtifactUploader artifacts: [
                    [
                        artifactId: 'webapp',
                        classifier: '',
                        file: 'target/webapp.war',
                        type: 'war'
                    ]
                ],
                credentialsId: 'Nexus',
                groupId: 'com.mycompany.webapp',
                nexusUrl: '3.111.72.154:8081',
                nexusVersion: 'nexus3',
                protocol: 'http',
                repository: 'maven-snapshots',
                version: '1.0-SNAPSHOT'
            }
        }
        stage('Building Image') {
            steps {
                sh 'docker image build -t 3.111.72.154:8083/webapp:${BUILD_ID} .'
            }
        }
        stage('Pushing Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Nexus', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh '''
                    docker login -u ${username} -p ${password} 3.111.72.154:8083
                    docker push 3.111.72.154:8083/webapp:${BUILD_ID}
                    docker rmi 3.111.72.154:8083/webapp:${BUILD_ID}
                    '''
                }
            }
        }
    }
    post {
        always {
            dependencyCheckPublisher (
            pattern: '',
            failedNewCritical: 0.1,
            failedNewHigh: 0.1,
            failedNewLow: 0.1,
            failedNewMedium: 0.1,
            failedTotalCritical: 0.1,
            failedTotalHigh: 0.1,
            failedTotalLow: 0.1,
            failedTotalMedium: 0.1,
            unstableNewCritical: 0.1,
            unstableNewHigh: 0.1,
            unstableNewLow: 0.1,
            unstableNewMedium: 0.1,
            unstableTotalCritical: 0.1,
            unstableTotalHigh: 0.1,
            unstableTotalLow: 0.1,
            unstableTotalMedium: 0.1
          )
        script {
            if(currentBuild.result == 'UNSTABLE') {
                unstable('UNSTABLE: Dependency check')
            } else if(currentBuild.result == 'FAILURE') {
                error('FAILED: Dependency check')
            }
        }
        }
    }
}