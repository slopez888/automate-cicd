pipeline {
    agent any

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Syntax Check') {
            steps {
                sh  "ansible-playbook -i app1, hackathons/rhte-2018-emea/playbook-ansible-role-banner.yaml --syntax-check"
            }
        }

        stage('Dry run') {
            steps {
                sh  "ansible-playbook -u ec2-user -i app1, hackathons/rhte-2018-emea/playbook-ansible-role-banner.yaml --check"
            }
        }

        stage('Execute Playbook') {
            steps {
                sh  "ansible-playbook -u ec2-user -i app1, hackathons/rhte-2018-emea/playbook-ansible-role-banner.yaml"
            }
        }
    }


}
