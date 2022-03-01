pipeline {
    agent any
    stages {
        stage('Building Artifacts') {
            steps {
                sh 'mvn clean package'
            }
        }
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
                dependencyCheckPublisher (
                    pattern: '',
                    failedNewCritical: 0,
                    failedNewHigh: 0,
                    failedNewLow: 0,
                    failedNewMedium: 0,
                    failedTotalCritical: 0,
                    failedTotalHigh: 0,
                    failedTotalLow: 0,
                    failedTotalMedium: 0,
                    unstableNewCritical: 0,
                    unstableNewHigh: 0,
                    unstableNewLow: 0,
                    unstableNewMedium: 0,
                    unstableTotalCritical: 0,
                    unstableTotalHigh: 0,
                    unstableTotalLow: 0,
                    unstableTotalMedium: 0
                )
                script {
                    if(currentBuild.result == 'UNSTABLE') {
                    unstable('Dependency check: UNSTABLE')
                    } else if(currentBuild.result == 'FAILURE') {
                        error('Dependency check: FAILED')
                    }
                }
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
                sh 'docker image build -t surya-aws.tk/webapp:${BUILD_ID} .'
            }
        }
        stage('Pushing Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Nexus', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh '''
                    docker login -u ${username} -p ${password} surya-aws.tk
                    docker push surya-aws.tk/webapp:${BUILD_ID}
                    '''
                }
            }
        }
        stage('Deploying to Cluster') {
            steps {
                sh 'envsubst < application.yaml | kubectl apply -f -'
            }
        }
    }
    post {
        always {
            sh 'docker rmi surya-aws.tk/webapp:${BUILD_ID}'
            cleanWs()
        }
    }
}