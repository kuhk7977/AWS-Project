pipeline {
    agent any

    environment {
        REGION = 'ap-northeast-2'
        EKS_CLUSTER_NAME = 'kosa'
        ECR_PATH = '730335210712.dkr.ecr.ap-northeast-2.amazonaws.com/kosa-repo'
        ECR_IMAGE = 'was'
        AWS_CREDENTIAL_ID = 'AWSCredentials'
        ECR_REGISTRY = '730335210712.dkr.ecr.ap-northeast-2.amazonaws.com'
        ARGOCD_SERVER = 'https://argo.fresh-chicken.org'
        ARGOCD_AUTH_TOKEN = 'argocd-token'
        APP_NAME = 'myapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-account', url: '깃허브이메일'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    kanikoBuildAndPush(env.ECR_IMAGE, 'Dockerfile')
                }
            }
        }

        stage('Deploy to EKS via Argo CD') {
            steps {
                script {
                    def syncApp = """
                    curl -X POST ${env.ARGOCD_SERVER}/api/v1/applications/${env.APP_NAME}/sync \\
                        -H "Authorization: Bearer ${env.ARGOCD_AUTH_TOKEN}" \\
                        -H "Content-Type: application/json" \\
                        -d '{}'
                    """

                    sh syncApp
                    sh 'sleep 10'  // 잠시 대기하여 동기화가 시작되도록 함
                }
            }
        }
    }
}

def kanikoBuildAndPush(imageName, dockerfile) {
    sh """
    # Create Kaniko pod YAML
    cat > kaniko-pod.yaml <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: kaniko-${imageName}-${env.BUILD_NUMBER}
      namespace: default
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        args:
          - "--context=dir:///workspace"
          - "--dockerfile=/workspace/kaniko.dockerfile"
          - "--destination=${env.ECR_REGISTRY}/${imageName}:${env.BUILD_NUMBER}"
          - "--oci-layout-path=/kaniko/oci"
        volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
          readOnly: true
        - name: workspace
          mountPath: /workspace

      restartPolicy: Never
      volumes:
      - name: kaniko-secret
        secret:
          secretName: kaniko-secret
      - name: workspace
        emptyDir: {}
    EOF

    # Apply Kaniko pod YAML using kubectl
    kubectl apply -f kaniko-pod.yaml

    # Wait for Kaniko pod to complete
    kubectl wait --for=condition=Complete pod/kaniko-${imageName}-${env.BUILD_NUMBER} --timeout=600s

    # Delete Kaniko pod
    kubectl delete pod kaniko-${imageName}-${env.BUILD_NUMBER}
    """
}
