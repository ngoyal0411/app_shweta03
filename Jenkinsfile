pipeline {
    agent any

    environment {
        scannerHome = tool name : 'sonar_scanner_dotnet'
        username = 'shweta03'
        repository = 'shweyasingh/app-shweta03'
    }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '5'))
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
                bat 'dotnet build -c Release'
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
                echo 'Docker image creation step'
                bat "docker build -t i-${username}-${BRANCH_NAME}:${BUILD_NUMBER} --no-cache -f Dockerfile ."

                echo 'Docker image tagging step'
                bat "docker tag i-${username}-${BRANCH_NAME}:${BUILD_NUMBER} ${repository}-${BRANCH_NAME}:${BUILD_NUMBER}"
                bat "docker tag i-${username}-${BRANCH_NAME}:${BUILD_NUMBER} ${repository}-${BRANCH_NAME}:latest"
            }
        }

        stage('Containers') {
            parallel {
                stage('PreContainerCheck') {
                    steps {
                        echo 'Pre container check step'
                        script {
                            if (env.BRANCH_NAME == 'master') {
                                env.docker_port = 7200
                            } else {
                                env.docker_port = 7300
                            }

                            env.container_id = bat(script:"docker ps -qf name=c-${username}-${BRANCH_NAME}", returnStdout: true).trim().readLines().drop(1).join('')

                            if (env.container_id != '') {
                                echo 'Stop and remove existing container'
                                bat "docker stop c-${username}-${BRANCH_NAME} && docker rm c-${username}-${BRANCH_NAME}"
                            }
                        }
                    }
                }

                stage('PushToDockerHub') {
                    steps {
                        echo 'Push docker image to docker hub step'
                        withDockerRegistry([credentialsId: 'DockerHub', url: '']) {
                            bat "docker push ${repository}-${BRANCH_NAME}:${BUILD_NUMBER}"
                            bat "docker push ${repository}-${BRANCH_NAME}:latest"
                        }
                    }
                }
            }
        }

        stage('Docker deployment') {
            steps {
                echo 'Docker deployment step'
                bat "docker run --name c-${username}-${BRANCH_NAME} -d -p ${docker_port}:80 ${repository}-${BRANCH_NAME}:latest"
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
