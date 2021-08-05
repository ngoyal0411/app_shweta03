pipeline {
    agent any

    environment {
        scannerHome = tool name : 'sonar_scanner_dotnet'
        username = 'shweta03'
    }

    options {
        timestamps()
        timeout(activity: true, time: 1, unit: 'HOURS')
    }

    stages {
        stage('NuGet restore') {
            steps {
                echo 'Code checkout step'
                checkout scm

                echo 'NuGet restore step'
                bat 'dotnet restore'
            }
        }

        stage('Start sonarQube analysis') {
            when {
                branch 'master'
            }
            steps {
                echo 'Start sonarqube analysis step'
                withSonarQubeEnv('Test_Sonar') {
                    bat "${scannerHome}\\SonarScanner.MSBuild.exe begin /k:sonar-${username} /n:sonar-${username} /v:1.0"
                }
            }
        }

        stage('Code build') {
            steps {
                echo 'Clean previous build'
                bat 'dotnet clean'

                echo 'Code build started'
                bat 'dotnet build -c Release -o "DevOpsAssignment/app/build"'
                bat 'dotnet test DevOpsAssignment.Tests\\DevOpsAssignment.Tests.csproj -l:trx;logFileName=TestOutput.xml'
            }
        }

        stage('Stop sonarQube analysis') {
            when {
                branch 'master'
            }
            steps {
                echo 'Stop sonarqube analysis step'
                withSonarQubeEnv('Test_Sonar') {
                    bat "${scannerHome}\\SonarScanner.MSBuild.exe end"
                }
            }
        }

        stage('Release artifact') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Release artifact step'
                bat 'dotnet publish -c Release'
            }
        }

        stage('Docker Image') {
            steps {
                echo 'Docker image step'
                bat 'dotnet publish -c Release'
                bat "docker build -t i-${username}-${BRANCH_NAME} --no-cache -f Dockerfile ."
            }
        }

        stage('Containers') {
            parallel {
                stage('PreContainerCheck') {
                    steps {
                        echo 'Pre container check'
                        script {
                            if (env.BRANCH_NAME == 'master') {
                                env.docker_port = 7200
                            } else {
                                env.docker_port = 7300
                            }

                            try {
                                bat "docker stop c-${username}-${BRANCH_NAME} && docker rm c-${username}-${BRANCH_NAME}"
                            }
                            catch (exc) {
                                echo 'No such container exist.'
                            }
                        }
                    }
                }

                stage('PushToDockerHub') {
                    steps {
                        echo 'Push docker image to docker hub step'
                        bat "docker tag i-${username}-${BRANCH_NAME} shweyasingh/i-${username}-${BRANCH_NAME}:${BUILD_NUMBER}"
                        bat "docker tag i-${username}-${BRANCH_NAME} shweyasingh/i-${username}-${BRANCH_NAME}:latest"

                        withDockerRegistry([credentialsId: 'DockerHub', url: '']) {
                            bat "docker push shweyasingh/i-${username}-${BRANCH_NAME}:${BUILD_NUMBER}"
                            bat "docker push shweyasingh/i-${username}-${BRANCH_NAME}:latest"
                        }
                    }
                }
            }
        }

        stage('Docker deployment') {
            steps {
                echo 'Docker deployment step'
                bat "docker run --name c-${username}-${BRANCH_NAME} -d -p ${docker_port}:80 shweyasingh/i-${username}-${BRANCH_NAME}:${BUILD_NUMBER}"
            }
        }

        stage('Kubernetes deployment') {
            steps {
                echo 'Kubernetes deployment step'
                bat 'kubectl apply -f k8s/deployment.yaml'
                bat 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
