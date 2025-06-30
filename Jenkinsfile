pipeline {
    agent { label 'builduser' }	

tools {
    maven "maven_3.6.3"
}

	environment {	
		DOCKERHUB_CREDENTIALS=credentials('dockerloginid')
	} 
    
    stages {
        stage('SCM Checkout') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/yash1999v/star-agile-insurance-project.git'
                
            }
		}
        stage('Maven Build') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean package"
            }
		}
       stage("Docker build"){
            steps {
				sh 'docker version'
				sh "docker build -t yash1999v/insureapp:${BUILD_NUMBER} ."
				sh 'docker image list'
				sh "docker tag yash1999v/insureapp:${BUILD_NUMBER} yash1999v/insureapp:latest"
            }
        }
		stage('Login2DockerHub') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}
		stage('Push2DockerHub') {

			steps {
				sh "docker push yash1999v/insureapp:latest"
			}
		}
        stage('Deploy to Kubernetes Dev Environment') {
    steps {
        script {
            sshPublisher(publishers: [
                sshPublisherDesc(
                    configName: 'Kubernetes',
                    transfers: [
                        sshTransfer(
                            sourceFiles: 'insure_kubernetesdeploy.yaml',
                            remoteDirectory: '',
                            execCommand: '''
                                echo "[INFO] Remote Host: $(hostname)"
                                echo "[INFO] Current User: $(whoami)"

                                echo "[INFO] Checking kubectl version..."
                                which kubectl || echo "kubectl not found"
                                kubectl version --client || echo "kubectl not working"

                                echo "[INFO] Kubeconfig context:"
                                kubectl config current-context || echo "No current context"

                                echo "[INFO] Listing deployment directory..."
                                ls -l /home/ubuntu/k8s-deploy

                                echo "[INFO] Applying Kubernetes manifest..."
                                cd /home/ubuntu/k8s-deploy
                                kubectl apply -f insure_kubernetesdeploy.yaml || echo "[ERROR] Failed to apply manifest"
                            ''',
                            execTimeout: 120000,
                            flatten: true,
                            cleanRemote: false,
                            makeEmptyDirs: false,
                            noDefaultExcludes: false,
                            patternSeparator: '[, ]+',
                            remoteDirectorySDF: false,
                            removePrefix: ''
                        )
                    ],
                    verbose: true,
                    usePromotionTimestamp: false,
                    useWorkspaceInPromotion: false
                )
            ])
        }
    }
}


    }
}
