# 0. Read Container Number parameter
if [ "$1" == "" ]; then
  echo "Sintax $0 <Container Number to Remove>"
  exit
fi
MIN=2
let MAX=$1+1

# 1. For each N => kill container and remove container. At the very end remove images too
for i in `seq $MIN $MAX`; do docker kill ubuntu$i; docker rm ubuntu$i; done; docker rmi ubuntu_sshd
