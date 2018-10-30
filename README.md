# Docker
Docker Example Use

## <a href=createN.sh>createN.sh</a> Create N Containers
```
# Commands to use Docker
# 0. Read Container Number parameter
if [ "$1" == "" ]; then
  echo "Sintax $0 <Container Number to Create>"
  exit
fi

# 1. Create network
docker network create --subnet 192.168.10.0/24 localnet

# 2. Build image ubuntu_sshd
docker build -t ubuntu_sshd .

# 3. Create and execute on background new container from ubuntu_sshd
MIN=2
let MAX=$1+1
for i in `seq $MIN $MAX`; do
  IP="192.168.10.$i"
  CONTAINER_NAME="ubuntu"$i
  # 3.1. Delete old entry from known_hosts about IP address
  ssh-keygen -f "/home/berto/.ssh/known_hosts" -R $IP 1>/dev/null 2>&1
  # 3.2. Create and Run New Container
  docker run -d --name $CONTAINER_NAME --net localnet --ip $IP ubuntu_sshd 1>/dev/null 2>&1
  # 3.3. Message for connecting
  echo "Use 'ssh -o StrictHostKeyChecking=no root@$IP' to connect to $CONTAINER_NAME"
done
```

## <a href=removeN.sh>removeN.sh</a> Remove N Containers
```
# 0. Read Container Number parameter
if [ "$1" == "" ]; then
  echo "Sintax $0 <Container Number to Remove>"
  exit
fi
MIN=2
let MAX=$1+1

# 1. For each N => kill container and remove container. At the very end remove images too
for i in `seq $MIN $MAX`; do docker kill ubuntu$i; docker rm ubuntu$i; done; docker rmi ubuntu_sshd
```

## <a href=Dockerfile>Dockerfile</a> Dockerfile used to create main image automatic accepting connection with PKEY
```
# Dockerfile ubuntu example

# Create from ubuntu
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir -p /root/.ssh
COPY id_rsa.pub /root/.ssh/authorized_keys2
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys2

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```
