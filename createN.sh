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

