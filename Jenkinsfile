pipeline {
    agent any

    environment {
        scannerHome = tool name : 'sonar_scanner_dotnet'
        registry = 'shweyasingh/i-shweta03-master'
        branch_name = 'master'
        docker_port = 7200
        username = 'shweta03'
        project_id = 'sampleapi-321108'
        cluster_name = 'dotnet-api'
        location = 'us-central1-c'
        credentials_id = 'GCP_SampleAPI'
        namespace = 'kubernetes-cluster-shweta03'
        container_id = "${bat(script:'docker ps -q --filter name=c-shweta03-master', returnStdout: true).trim().readLines().drop(1).join('')}"
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
            }
        }

        stage('Stop sonarQube analysis') {
            steps {
                echo 'Stop sonarqube analysis step'
                withSonarQubeEnv('Test_Sonar') {
                    bat "${scannerHome}\\SonarScanner.MSBuild.exe end"
                }
            }
        }

        stage('Docker Image') {
            steps {
                echo 'Docker image step'
                bat 'dotnet publish -c Release'
                bat "docker build -t i-${username}-${branch_name} --no-cache -f Dockerfile ."
            }
        }

        stage('Containers') {
            parallel {
                stage('PreContainerCheck') {
                    steps {
                        echo 'Pre container check'
                        script {
                            if (env.container_id != null) {
                                echo 'Stop and remove existing container'
                                bat "docker stop c-${username}-${branch_name} && docker rm c-${username}-${branch_name}"
                            }
                        }
                    }
                }

                stage('PushToDockerHub') {
                    steps {
                        echo 'Push docker image to docker hub step'
                        bat "docker tag i-${username}-${branch_name} shweyasingh/i-${username}-${branch_name}:${BUILD_NUMBER}"
                        bat "docker tag i-${username}-${branch_name} shweyasingh/i-${username}-${branch_name}:latest"

                        withDockerRegistry([credentialsId: 'DockerHub', url: '']) {
                            bat "docker push shweyasingh/i-${username}-${branch_name}:${BUILD_NUMBER}"
                            bat "docker push shweyasingh/i-${username}-${branch_name}:latest"
                        }
                    }
                }
            }
        }

        stage('Docker deployment') {
            steps {
                echo 'Docker deployment step'
                bat "docker run --name c-${username}-${branch_name} -d -p ${docker_port}:80 shweyasingh/i-${username}-${branch_name}:${BUILD_NUMBER}"
            }
        }

        stage('Kubernetes deployment') {
            steps {
                echo 'Kubernetes deployment step'
                step([$class: 'KubernetesEngineBuilder', projectId: env.project_id, clusterName: env.cluster_name, location: env.location, namespace: env.namespace, manifestPattern: 'k8s/deployment.yaml', credentialsId: env.credentials_id, verifyDeployments: true])
                step([$class: 'KubernetesEngineBuilder', projectId: env.project_id, clusterName: env.cluster_name, location: env.location, namespace: env.namespace, manifestPattern: 'k8s/service.yaml', credentialsId: env.credentials_id, verifyDeployments: false])
            }
        }
    }
}
