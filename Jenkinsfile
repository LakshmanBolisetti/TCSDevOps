pipeline {
    agent any
    stages {
        stage('code') {
            steps {
                git 'https://github.com/LakshmanBolisetti/TCSDevOps.git'
            }
        }
        stage('init') {
            steps {
                    sh 'terraform init'
            }
        }
        stage('plan') {
            steps {
                   withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                      sh 'terraform plan'     
                   }              
            }
        }
        stage('apply') {
            steps {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWSCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                      sh 'terraform apply --auto-approve'     
                }
            }
        }
    }
}
