aws ec2-instance-connect send-ssh-public-key --instance-id i-0e601be2572a4e95e --availability-zone ap-south-1a --instance-os-user ec2-user --ssh-public-key ~/.ssh/jump_host.pub

aws ssm start-session --target i-0e601be2572a4e95e

ssh -f -N ec2-user@i-0e601be2572a4e95e