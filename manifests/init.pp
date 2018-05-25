# Class: localadmin
# ===========================
#
# This class expects to be called with 3 parameters that are then passed to a define, either mac_setup or linux_setup, depending on the OS.
#
# Parameters
# ----------
#
# macadmins is a hash containing the atributes for creating a user in a MacOS system.
# hide_macadmins is a string, that defines wheater users with a UID less than 500 should be hidden. Possible values are TRUE or FALSE.
# linuxadmins is a hash containing the atributes for creating a user in a Debian/Ubuntu system.
#
# Examples
# --------
#
# Please see the readme.
#
class localadmin {
  case $kernel {
    'Darwin': {
      $macadmins = lookup(localadmin_macadmins)
      $hide_macadmins = lookup(localadmin_hide_macadmins)
      
      group { 'com.apple.access_ssh':
        name   => 'com.apple.access_ssh',
        ensure => present,
      }
      $macadmins.each |$admin_name, $args_array| {
        localadmin::mac_setup { "$admin_name":
          local_admin    => $args_array[local_admin],
          gid            => $args_array[gid],
          iterations     => $args_array[iterations],
          password       => $args_array[password],
          salt           => $args_array[salt],
          uid            => $args_array[uid],
          ssh_keyname    => $args_array[ssh_keyname],
          ssh_key        => $args_array[ssh_key],
          hide_macadmins => $hide_macadmins,
        }
      }
    }
    'Linux': {
      $linuxadmins = lookup(localadmin_linuxadmins)
    
      class { 'sudo':
        config_file_replace => false,
      }
      $linuxadmins.each |$admin_name, $args_array| {
        localadmin::linux_setup { "$admin_name":
          local_admin => $args_array[local_admin],
          password    => $args_array[password],
          ssh_keyname => $args_array[ssh_keyname],
          ssh_key     => $args_array[ssh_key],
        }
      }
    }
    default: {
      notify { "Non supported operating system detected: $::osfamily": }
    }
  }
}
