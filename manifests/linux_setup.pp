define localadmin::linux_setup (
  $local_admin,
  $password,
  $ssh_keyname,
  $ssh_key,
) {
  user {"$local_admin":
    ensure     => present,
    password   => "$password",
    comment    => 'Local Admin',
    groups     => ['cdrom', 'floppy', 'audio', 'dip', 'video', 'plugdev', 'netdev'],
    home       => "/home/$local_admin",
    shell      => '/bin/bash',
    managehome => true,
  }

  ssh_authorized_key {"$ssh_keyname":
    ensure => present,
    user   => "$local_admin",
    type   => 'ssh-rsa',
    key    => "$ssh_key",
  }

  sudo::conf {"$local_admin":
    ensure  => present,
    content => "%$local_admin ALL=(ALL) ALL",
  }
}
