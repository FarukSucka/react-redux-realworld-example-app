node (label: 'master'){
    def app
    env.TOKEN = "faruk-slack"
    env.SLACK_TEAM_DOMAIN = "mopdevs" 
    env.SLACK_CHANNEL = "taskbuilds"
    env.MSG_PREFIX = "*${env.JOB_NAME}-${env.BUILD_NUMBER}*"
    env.CONSOLEURL = "`${env.BUILD_URL}console`"

    stage ('Properties') {
        properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '2', numToKeepStr: '10')), disableConcurrentBuilds(), pipelineTriggers([githubPush()])])    
        }

    stage('Clone repository') {
        checkout scm
    }

    nodejs('faruksuljic') {
        try {
            retry (2){
                sh "npm install"
                sh "rm -rf dist"
                sh "mkdir -p dist"
                sh "REACT_APP_API_ROOT=https://faruk-staging.faruksuljic.com npm run-script build && mv build dist/staging"
                sh "REACT_APP_API_ROOT=https://faruk-production.faruksuljic.com npm run-script build && mv build dist/production"
                //sh '/var/lib/jenkins/workspace/staging/build.sh --environment staging'
                //sh '/var/lib/jenkins/workspace/staging/build.sh --environment production'
                sh "tar -zcvf ${env.JOB_NAME}-${env.BUILD_NUMBER}.tar.gz ./dist/"
            }
        } catch (e) {
            slackSend message: "${MSG_PREFIX} - Build failed during `Build` stage",
                color: "danger ",
                channel: "${SLACK_CHANNEL}",
                teamDomain: "${env.SLACK_TEAM_DOMAIN}",
                tokenCredentialId: "${env.TOKEN}"
            throw(e)
        }
    }

    stage('Upload artifact') {
        retry(2) {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'faruk-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh "aws s3 cp ${env.JOB_NAME}-${env.BUILD_NUMBER}.tar.gz s3://faruk-artifacts/${env.JOB_NAME}-${env.BUILD_NUMBER}.tar.gz"
            }
        slackSend message: "${MSG_PREFIX} - Uploaded artifact to S3",
            color: "good",
            channel: "${SLACK_CHANNEL}",
            teamDomain: "${env.SLACK_TEAM_DOMAIN}",
            tokenCredentialId: "${env.TOKEN}"
        }
    }

    stage('Deploy') {
        try {
            retry(2) {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'faruk-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh "aws s3 sync --acl public-read --sse --delete dist/staging s3://faruk-staging.faruksuljic.com"
                    }
            slackSend message: "${MSG_PREFIX} - Deployed to S3",
                color: "good",
                channel: "${SLACK_CHANNEL}",
                teamDomain: "${env.SLACK_TEAM_DOMAIN}",
                tokenCredentialId: "${env.TOKEN}"
            }
        } catch (e) {
            slackSend message: "${MSG_PREFIX} - Build failed during `Deploy` stage",
                color: "danger",
                channel: "${SLACK_CHANNEL}",
                teamDomain: "${env.SLACK_TEAM_DOMAIN}",
                tokenCredentialId: "${env.TOKEN}"
            throw(e)
        }
    }
    stage('Invalidation') {
        try {
            retry(2) {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'faruk-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh "aws cloudfront create-invalidation --distribution-id E1547LZ7K7NC66 --paths '/*'"
                    }
            slackSend message: "${MSG_PREFIX} - CloudFront Invalidated",
                color: "good",
                channel: "${SLACK_CHANNEL}",
                teamDomain: "${env.SLACK_TEAM_DOMAIN}",
                tokenCredentialId: "${env.TOKEN}"
            }
        } catch (e) {
            slackSend message: "${MSG_PREFIX} - Failed at invalidation@CF",
                color: "danger",
                channel: "${SLACK_CHANNEL}",
                teamDomain: "${env.SLACK_TEAM_DOMAIN}",
                tokenCredentialId: "${env.TOKEN}"
            throw(e)
        }
    }
    stage ('Cleanup'){
        cleanWs cleanWhenFailure: false
    }
}
