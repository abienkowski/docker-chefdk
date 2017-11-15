#!/bin/sh

# -- --
# -- add user
id $USER 2&>1 /dev/null
if [ "$?" -ne "0" ]; then
  groupadd -g 1000 $USER
  useradd -m -g $USER -s /bin/bash -u 1000 $USER
fi

# -- add sudo priviledges
if [ ! -f /etc/sudoers.d/$USER ]; then
  echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER
fi

# -- add chef environment
echo 'eval "$(chef shell-init bash)"' >> /home/$USER/.bashrc

# -- setup ssh directory
if [ ! -d /home/$USER/.ssh ]; then
  su - $USER -c "ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''"
  # -- output public key to console, so it can used to login from host
  cat /home/$USER/.ssh/id_rsa
fi

# -- add the created key to authrorized_keys
if [ ! -f /home/$USER/.ssh/authorized_keys ]; then
  cat /home/$USER/.ssh/id_rsa.pub > /home/$USER/.ssh/authorized_keys
  chmod 600 /home/$USER/.ssh/authorized_keys
  chown $USER:$USER /home/$USER/.ssh/authorized_keys
fi

# -- bind the mounted wa directory
if [ ! -d /home/$USEr/wa ]; then
  mkdir -p /home/$USER/wa
  chown $USER:$USER /home/$USER/wa
fi

# -- bind mount external volume to user home directory
sudo mount -o bind,uid=1000,gid=1000 /mnt/${USER}-wa /home/$USER/wa

# -- start sshd
/usr/sbin/sshd -D
