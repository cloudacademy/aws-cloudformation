# Fraud Detection CloudFormation Templates
Contains YAML CloudFormation templates used to build 2 example serverful environments.

## Environment 1 - Simple

### Files
* `cloudacademy.vpc.ml.yaml`

### Overview
The creation of this environment involves spinning up a single CloudFormation stack using just the template `cloudacademy.vpc.ml.yaml`.

This environment consists of an EC2 instance. The EC2 instance bootstraps itself at launch time. The bootsrapping sequence involves cloning from a CA FraudDetection GITHUB repository, downloads a sample credit card dataset, then installs itself, builds the model, and then finally spins up HTTP API endpoint - to which prediction requests can be sent to.

### EC2 Userdata Bootstrapping Script
```
#!/bin/bash
exec > >(tee /var/log/userdata.log)
exec 2>&1
whoami
echo deployment script 1.0

echo =======================================
                
apt-get update -y
apt-get install python-pip -y
apt-get install unzip -y
pip install virtualenv
mkdir /ml
cd /ml
virtualenv frauddetectionenv
source frauddetectionenv/bin/activate
git clone https://github.com/cloudacademy/fraud-detection
cd fraud-detection
pip install -r requirements-dev.txt
curl -O https://clouda-datasets.s3.amazonaws.com/creditcard.csv.zip
unzip creditcard.csv.zip
mv creditcard.csv ./data/
python src/train.py 
export FLASK_APP=src/flask_app.py

echo =======================================

printf "\n" >> src/flask_app.py
printf "@app.route(u\"/health\", methods=[u\"GET\"])\n" >> src/flask_app.py
printf "def health():\n" >> src/flask_app.py
printf "\treturn \"OK\", 200\n" >> src/flask_app.py

echo =======================================

printf "\napp.run(host='0.0.0.0', debug=False)\n" >> src/flask_app.py
flask run
```

### AWS Components
This environment consists of the following AWS infrastructure items created by CloudFormation:

* VPC
* Subnet
* Internet Gateway
* Route Table
* EC2 Instance

### Installation
To install this environment, complete the following steps

1. Log into AWS Console, as a user with admin priviledges
2. Select the CloudFormation service
3. Launch a new CloudFormation stack - by uploading the `cloudacademy.vpc.ml.yaml` template
4. Leave all input parameter defaults as is - or adjust as neccessary
5. Once the CloudFormation stack has completed building successfully - take a look at the Outputs tab and copy the `FraudDetectionPredictCommand` value. The `FraudDetectionPredictCommand` contains a ready to use CURL command to fire in a fraud detection request. An example of this command follows:

Note: This command needs to run from within the `vpc-ml` folder as it references the `fraudtest.json` test file.

Note: The endpoint listens on port 5000 and hits EC2 instance public IP 

```
curl --header 'Content-Type: application/json' -vX POST http://52.18.231.127:5000/predict -d @fraudtest.json
*   Trying 52.18.231.127...
* Connected to 52.18.231.127 (52.18.231.127) port 5000 (#0)
> POST /predict HTTP/1.1
> Host: 52.18.231.127:5000
> User-Agent: curl/7.43.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 555
>
* upload completely sent off: 555 out of 555 bytes
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Content-Type: text/html; charset=utf-8
< Content-Length: 33
< Server: Werkzeug/0.12.2 Python/2.7.12
< Date: Thu, 10 Aug 2017 04:24:44 GMT
<
* Closing connection 0
{"scores": [0.19899620710890045]}
```

## Environment 2 - Complex

### Files
* `cloudacademy.buildenv.yaml` - Part1 (Buildtime Components)
* `cloudacademy.vpc.ml.ecs.yaml` - Part2 (Runtime Components)

### Overview
The creation of this environment involves spinning up two CloudFormation stacks using the templates `cloudacademy.buildenv.yaml` and `cloudacademy.vpc.ml.ecs.yaml`, in this order.

This environment consists of two distinct parts:

### Part 1 - Build Environment
AWS CodeBuild which creates a Docker Image containing the fraud detection model. The CodeBuild build phase involves cloning from a CA FraudDetection GITHUB repository, downloads a sample credit card dataset, then installs itself, builds the model, and then finally sets up an HTTP API endpoint - to which prediction requests can be sent to. Once the Docker Image is succesfully built it is published into a custom ECR repository. 

### Part 2 - Runtime Environment
An AWS ECS cluster is spun up. The ECS cluster sits behind a Application Load Balancer (ALB). The ECS cluster in this demo consists of a single EC2 instance.
The ECS cluster hosts a single Service which in turn is configured to run 2 tasks - based on the Docker Image created in Part 1 and stored in ECR. Incoming Fraud Detection request are aimed at the ALB - which in turns forwards them downstream to the running Docker contains on the ECS cluster.

### CodeBuild BuildSpec
```
version: 0.2

# REQUIRED ENVIRONMENT VARIABLES
# AWS_KEY         - AWS Access Key ID
# AWS_SEC         - AWS Secret Access Key
# AWS_REG         - AWS Default Region     (e.g. us-west-2)
# AWS_OUT         - AWS Output Format      (e.g. json)
# AWS_PROF        - AWS Profile name       (e.g. central-account)
# IMAGE_REPO_NAME - Name of the image repo (e.g. my-app)
# IMAGE_TAG       - Tag for the image      (e.g. latest)
# AWS_ACCOUNT_ID  - Remote AWS account id  (e.g. 555555555555)

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --region ${AWS_REG})
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REG.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REG.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
```

### CodeBuild Dockerfile
```
FROM ubuntu:16.04
MAINTAINER CloudAcademy <jeremy.cook@cloudacademy.com>

RUN apt-get update -y 
RUN apt-get install python-pip -y
RUN apt-get install unzip -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN pip install virtualenv
RUN virtualenv /ml/frauddetectionenv
RUN /bin/bash -c "source /ml/frauddetectionenv/bin/activate" 
RUN git clone https://github.com/cloudacademy/fraud-detection /ml/fraud-detection
RUN pip install -r /ml/fraud-detection/requirements-dev.txt
RUN curl -o /ml/fraud-detection/data/creditcard.csv.zip https://clouda-datasets.s3.amazonaws.com/creditcard.csv.zip
RUN unzip /ml/fraud-detection/data/creditcard.csv.zip -d /ml/fraud-detection/data
RUN ls -la /ml/fraud-detection/data
RUN df -h
RUN JOBLIB_TEMP_FOLDER=/tmp python /ml/fraud-detection/src/train.py 
RUN export FLASK_APP=/ml/fraud-detection/src/flask_app.py
RUN printf "\n" >> /ml/fraud-detection/src/flask_app.py
RUN printf "@app.route(u\"/health\", methods=[u\"GET\"])\n" >> /ml/fraud-detection/src/flask_app.py
RUN printf "def health():\n" >> /ml/fraud-detection/src/flask_app.py
RUN printf "\treturn \"OK\", 200\n" >> /ml/fraud-detection/src/flask_app.py
RUN printf "\napp.run(host='0.0.0.0', debug=False)\n" >> /ml/fraud-detection/src/flask_app.py

EXPOSE 5000

WORKDIR /ml/fraud-detection/
ENV FLASK_APP /ml/fraud-detection/src/flask_app.py 
CMD ["flask", "run"]
```


### AWS Components
This environment consists of the following AWS infrastructure items created by CloudFormation:

Buildtime Components
* CodeBuild
* ECR
* Docker Image

Runtime Components
* ECS Cluster
* ECS Service
* ECS Task
* ALB
* VPC
* Subnet
* Internet Gateway
* Route Table
* EC2 Instance

### Installation
To install this environment, complete the following steps

Part1 (Buildtime Components):
`cloudacademy.buildenv.yaml`
1. Log into AWS Console, as a user with admin priviledges
2. Select the CloudFormation service
3. Launch new CloudFormation stack - by uploading the `cloudacademy.buildenv.yaml` template
4. Leave all input parameter defaults as is - or adjust as neccessary
5. Once the CloudFormation stack has completed building successfully - navigate to the CodeBuild service within the AWS console.
6. Within CodeBuild select the newly created CodeBuild project and start build
7. Confirm that the build completes successfully - this will result in a new Docker Image published into a ECR repo.
8. Navigate to the ECR service within the AWS console, and confirm that a new fraud detection Docker Image has been successfully registered.

Part2 (Runtime Components):
`cloudacademy.vpc.ml.ecs.yaml`
9. Navigate back to the CloudFormation service
10. Launch new CloudFormation stack - by uploading the `cloudacademy.vpc.ml.ecs.yaml` template
11. Leave all input parameter defaults as is - or adjust as neccessary
12. Once the CloudFormation stack has completed building successfully - navigate to the ECS service within the AWS console.
13. Confirm that the new ECS fraud detection cluster has been created successfully. 
14. Confirm that the new ECS fraud detection cluster has been been configured with 1 Service, which in turn has been configured with 2 RUNNING Tasks.
16. Back within the CloudFormation service - take a look at the Outputs tab of the just built stack and copy the `FraudDetectionPredictCommand` value. The `FraudDetectionPredictCommand` contains a ready to use CURL command to fire in a fraud detection request. An example of this command follows:

Note: This command needs to run from within the `vpc-ml` folder as it references the `fraudtest.json` test file.

Note: The endpoint listens on port 80 and hits the ALB

```
curl --header 'Content-Type: application/json' -vX POST http://ECSALB-1049799994.eu-west-1.elb.amazonaws.com/predict -d @fraudtest.json
*   Trying 52.50.104.17...
* Connected to ECSALB-1049799994.eu-west-1.elb.amazonaws.com (52.50.104.17) port 80 (#0)
> POST /predict HTTP/1.1
> Host: ECSALB-1049799994.eu-west-1.elb.amazonaws.com
> User-Agent: curl/7.43.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 555
>
* upload completely sent off: 555 out of 555 bytes
< HTTP/1.1 200 OK
< Date: Thu, 10 Aug 2017 03:45:14 GMT
< Content-Type: text/html; charset=utf-8
< Content-Length: 33
< Connection: keep-alive
< Server: Werkzeug/0.12.2 Python/2.7.12
<
* Connection #0 to host ECSALB-1049799994.eu-west-1.elb.amazonaws.com left intact
{"scores": [0.19899620710890045]}
```
