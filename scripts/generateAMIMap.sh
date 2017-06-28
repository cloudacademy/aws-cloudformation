IMAGE_NAME="VyOS (HVM) 1.1.7"

aws ec2 describe-images --filter Name=name,Values="${IMAGE_NAME}" --query 'Images[0].ImageId' --output text --region us-east-2
us-west-1
us-west-2
ca-central-1
eu-west-1
eu-central-1
eu-west-2
ap-northeast-1
ap-northeast-2
ap-southeast-1
ap-southeast-2
ap-south-1
sa-east-1


getAMIID(){
    echo $1:
    AMI=`aws ec2 describe-images --filter Name=name,Values="VyOS (HVM) 1.1.7" --query 'Images[0].ImageId' --output text --region $1`
    echo -e "\tAMI: ${AMI}"
}

getAMIID us-east-1
getAMIID us-east-2
getAMIID us-west-1
getAMIID us-west-2
getAMIID ca-central-1
getAMIID eu-west-1
getAMIID eu-central-1
getAMIID eu-west-2
getAMIID ap-northeast-1
getAMIID ap-northeast-2
getAMIID ap-southeast-1
getAMIID ap-southeast-2
getAMIID ap-south-1
getAMIID sa-east-1



us-east-1:
	AMI: ami-b8e1a5af
us-west-1:
	AMI: ami-8597d9e5
us-west-2:
	AMI: ami-ac23fccc
eu-west-1:
	AMI: ami-b1f944c2
eu-central-1:
	AMI: ami-49cf3b26
ap-northeast-1:
	AMI: ami-5812e939
ap-northeast-2:
	AMI: ami-76e52f18
ap-southeast-1:
	AMI: ami-3df6525e
ap-southeast-2:
	AMI: ami-1b8bbb78
ap-south-1:
	AMI: ami-7034401f
sa-east-1:
	AMI: ami-1a37a476