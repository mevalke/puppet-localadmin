define localadmin::mac_setup (
  $local_admin,
  $gid,
  $iterations,
  $password,
  $salt,
  $uid,
  $ssh_keyname,
  $ssh_key,
  $hide_macadmins,
) {
  user { "$local_admin":
    ensure     	=> 'present',
    comment    	=> "$comment",
    gid        	=> "$gid",
    groups     	=> ['_appserveradm', '_appserverusr', '_lpadmin', 'admin', 'com.apple.access_ssh'],
    home       	=> "/Users/$local_admin",
    iterations 	=> "$iterations",
    password   	=> "$password",
    salt       	=> "$salt",
    shell      	=> '/bin/bash',
    uid        	=> "$uid",
  }
  group {"$local_admin":
    name        => "$local_admin",
    ensure      => present,
    members     => "$local_admin",
  }
  exec {"$name enable SSH":
    command     => '/usr/sbin/systemsetup -setremotelogin on',
    path        => '/bin, /usr/bin, /sbin, /usr/sbin',
    subscribe 	=> User["$local_admin"],
    refreshonly => true,
  }
  exec {"$name deny remote management from all":
    command 	=> '/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers >> /tmp/log',
    path 	=> '/bin, /usr/bin, /sbin',
    subscribe 	=> User["$local_admin"],
    refreshonly => true,
  } 
  exec {"$name grant remote management for local admin":
    command 	=> "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users $local_admin -privs -all -restart -agent -menu >> /tmp/log",
    path 	=> '/bin, /usr/bin, /sbin',
    subscribe 	=> User["$local_admin"],
    refreshonly => true,
  }  
  exec {"$name create home folder":
    command	=> '/usr/sbin/createhomedir -c',
    path        => '/bin, /usr/bin, /sbin, /usr/sbin',
    subscribe   => User["$local_admin"],
    refreshonly	=> true,
  }
  exec { "$name Hide sub-500 users":
    command     => "/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool $hide_macadmins",
    path        => '/bin, /usr/bin, /sbin, /usr/sbin',
    subscribe   => User["$local_admin"],
    refreshonly => true,
  }
  ssh_authorized_key { "$ssh_keyname":
    ensure 	=> present,
    user   	=> "$local_admin",
    type   	=> 'ssh-rsa',
    key    	=> "$ssh_key",
  }  
}
