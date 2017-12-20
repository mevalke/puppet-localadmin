# puppet_localadmin

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with puppet_localadmin](#setup)
    * [What puppet_localadmin affects](#what-puppet_localadmin-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_localadmin](#beginning-with-puppet_localadmin)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module adds admin users with sudo privileges in MacOS and Debian/Ubuntu systems. Users created can be used for remote management 
via SSH and Apple Remote Desktop.

This module is meant to be used in a multi tenant environment, where different customers have different requirements, thus it´s designed 
to be used with Hiera.

## Setup

### What puppet_localadmin affects

Aside of the desired user resources, the module also does the following.

On MacOS systems:

* SSH key is added in ~/.ssh/authorized_keys on each user profile the module creates.
* Each user created is added as a member of the admins group.
* MacOS admin users can be hidden by specifying the hide_macadmins parameter.  

On Debian/Ubuntu systems:

* SSH key is added in ~/.ssh/authorized_keys on each user profile it creates.
* Package sudo is installed and users created added in the sudoers group.

### Setup Requirements

Install the saz-sudo module.

```
puppet module install saz-sudo --version 4.2.0

```

### Beginning with puppet_localadmin

In order to use the module you need the following.
* SSH keypair
* Attributes for each MacOS user to be created.
* Attributes for each Linux user to be created.
 
Create an SSH key pair and cat out the content of the public key. 

```
ssh-keygen -f ~/.ssh/admin@example.com
cat ~/.ssh/admin@example.com.pub
```

Acquiring the user attributes on a Mac.

If you want set the uid and gid below 500 (and then hiding the users with id´s below 500), first check if the desired id is available.

```
dscl . list /Users UniqueID|grep 444
dscacheutil -q group|grep 444
```

Example of creation of a local admin account called 'admin1' with a password of 'Passw0rd'.

```
dscl . create /Users/admin1
dscl . create /Users/admin1 UserShell /bin/bash 
dscl . create /Users/admin1 RealName "Local Admin"
dscl . create /Users/admin1 UniqueID 444
dscl . create /Users/admin1 GroupID 444
dscl . create /Users/admin1 NFSHomeDirectory /Users/admin1
dscl . passwd /Users/admin1 Passw0rd
dscl . append /Groups/admin GroupMembership admin
```

Once the user has been created the attributes can be printed and re-used:

```
sudo puppet resource user admin1
user { 'admin1':
  ensure     => 'present',
  comment    => 'Local Admin',
  groups     => ['admin'],
  home       => '/Users/admin1',
  iterations => '42372',
  password   => '691f3f31a8de4f642674f066fcac5a5fdde8f8cf5347f3e2c9591f6ed7a98566eb01b8d03e52501881ef80613751a1ccbcc4f4305d0caa0ddaae0003280c93f1ebbcb11e2a7c7bd5aa69e88e097142472556fc3aa97efa8944ad71d9d419e9143cf3ea69cdf8fdf679e829bf7bd1b0b17749432013a6a20c6c6fe70bef6dce1d',
  salt       => '434df33ea9ad162babc43be7ad3c3aff6af0d59feff92bcf399b6d7b97603630',
  shell      => '/bin/bash',
  uid        => '444',
}
```

On Linux:

Generating a password hash to use in the user resource (remember to replace "Passw0rd" with the correct password):

```
root@server:/home/admin# python -c "import random,string,crypt;
> randomsalt = ''.join(random.sample(string.ascii_letters,8));
> print crypt.crypt('Passw0rd', '\$6\$%s\$' % randomsalt)"
$6$rwgFfKNe$SMn6VgH/2LZXeEQpG8qPHXmak8XPWJv1InId33mhXRrrNHrh5k8IEadRQtpg.mqghQQrPCucKZ2HSkIDPC7rZ.
```

## Usage

Sample Hiera configuration using the above attributes:

```
localadmin::macadmins:
  admin1:
   local_admin: 'admin1'
   gid: '20'
   iterations: '42372'
   password: '691f3f31a8de4f642674f066fcac5a5fdde8f8cf5347f3e2c9591f6ed7a98566eb01b8d03e52501881ef80613751a1ccbcc4f4305d0caa0ddaae0003280c93f1ebbcb11e2a7c7bd5aa69e88e097142472556fc3aa97efa8944ad71d9d419e9143cf3ea69cdf8fdf679e829bf7bd1b0b17749432013a6a20c6c6fe70bef6dce1d'
   salt: '434df33ea9ad162babc43be7ad3c3aff6af0d59feff92bcf399b6d7b97603630'
   uid: '444'
   ssh_keyname: 'admin1@example.com'
   ssh_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDNid0GR3NT2bOJhDU85skKLeC2qtuMuShZE8GtNTkR1S2a0wzt1IWKgf+L6wNG/+Z7FNX3THQsywEKguHpidyMl6pr2CPnnraNe/PS1XYlc0BeyZ7qwPWCqg9DxjtpKfKhQ0vGAZwcw/tExcVFQ5tL+jMevKYi6H+CdzgbY03p1md6Qdxw48aPBpARHmx/mKcNlbSbbR14mXyQI1sFhQheYniU6UJUNPL5+12LCPmdCbn2uoxoTKafHkCy7g4er58MgceszO9znpYOBFgr7lwTlR38DYczklaq1+cZi2eXM9/ZR1v0G6tZtNi9jgG1ZWr1V/5j0CWNOOBKGTNKWdw1'
  admin2:
   local_admin: 'admin2'
   gid: '20'
   iterations: '42372'
   password: '691f3f31a8de4f642674f066fcac5a5fdde8f8cf5347f3e2c9591f6ed7a98566eb01b8d03e52501881ef80613751a1ccbcc4f4305d0caa0ddaae0003280c93f1ebbcb11e2a7c7bd5aa69e88e097142472556fc3aa97efa8944ad71d9d419e9143cf3ea69cdf8fdf679e829bf7bd1b0b17749432013a6a20c6c6fe70bef6dce1d'
   salt: '434df33ea9ad162babc43be7ad3c3aff6af0d59feff92bcf399b6d7b97603630'
   uid: '445'
   ssh_keyname: 'admin.example.com'
   ssh_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDNid0GR3NT2bOJhDU85skKLeC2qtuMuShZE8GtNTkR1S2a0wzt1IWKgf+L6wNG/+Z7FNX3THQsywEKguHpidyMl6pr2CPnnraNe/PS1XYlc0BeyZ7qwPWCqg9DxjtpKfKhQ0vGAZwcw/tExcVFQ5tL+jMevKYi6H+CdzgbY03p1md6Qdxw48aPBpARHmx/mKcNlbSbbR14mXyQI1sFhQheYniU6UJUNPL5+12LCPmdCbn2uoxoTKafHkCy7g4er58MgceszO9znpYOBFgr7lwTlR38DYczklaq1+cZi2eXM9/ZR1v0G6tZtNi9jgG1ZWr1V/5j0CWNOOBKGTNKWdw1'
localadmin::hide_macadmins: 'FALSE'
localadmin::linuxadmins:
  admin1: 
   local_admin: 'admin1'
   password: '$6$rwgFfKNe$SMn6VgH/2LZXeEQpG8qPHXmak8XPWJv1InId33mhXRrrNHrh5k8IEadRQtpg.mqghQQrPCucKZ2HSkIDPC7rZ.'
   ssh_keyname: 'admin1@example.com'
   ssh_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDNid0GR3NT2bOJhDU85skKLeC2qtuMuShZE8GtNTkR1S2a0wzt1IWKgf+L6wNG/+Z7FNX3THQsywEKguHpidyMl6pr2CPnnraNe/PS1XYlc0BeyZ7qwPWCqg9DxjtpKfKhQ0vGAZwcw/tExcVFQ5tL+jMevKYi6H+CdzgbY03p1md6Qdxw48aPBpARHmx/mKcNlbSbbR14mXyQI1sFhQheYniU6UJUNPL5+12LCPmdCbn2uoxoTKafHkCy7g4er58MgceszO9znpYOBFgr7lwTlR38DYczklaq1+cZi2eXM9/ZR1v0G6tZtNi9jgG1ZWr1V/5j0CWNOOBKGTNKWdw1'
  admin2:
   local_admin: 'admin2'
   password: '$6$rwgFfKNe$SMn6VgH/2LZXeEQpG8qPHXmak8XPWJv1InId33mhXRrrNHrh5k8IEadRQtpg.mqghQQrPCucKZ2HSkIDPC7rZ.'
   ssh_keyname: 'admin@example.com'
   ssh_key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDNid0GR3NT2bOJhDU85skKLeC2qtuMuShZE8GtNTkR1S2a0wzt1IWKgf+L6wNG/+Z7FNX3THQsywEKguHpidyMl6pr2CPnnraNe/PS1XYlc0BeyZ7qwPWCqg9DxjtpKfKhQ0vGAZwcw/tExcVFQ5tL+jMevKYi6H+CdzgbY03p1md6Qdxw48aPBpARHmx/mKcNlbSbbR14mXyQI1sFhQheYniU6UJUNPL5+12LCPmdCbn2uoxoTKafHkCy7g4er58MgceszO9znpYOBFgr7lwTlR38DYczklaq1+cZi2eXM9/ZR1v0G6tZtNi9jgG1ZWr1V/5j0CWNOOBKGTNKWdw1'
```

Sample profile manifest:

```
class profiles::localadmin {
  $macadmins      = lookup(localadmin::macadmins)
  $hide_macadmins = lookup(localadmin::hide_macadmins)
  $linuxadmins    = lookup(localadmin::linuxadmins)
   
  class { 'puppet_localadmin':  
    macadmins      => $macadmins,
    linuxadmins    => $linuxadmins,
    hide_macadmins => $hide_macadmins,
  }
}
```

## Reference

* puppet_localadmin: Main class that requires 3 parameters and calls either puppet_localadmin::mac_setup or puppet_localadmin::linux_setup.
* puppet_localadmin::mac_setup: Sets up the users in MacOS.
* puppet_localadmin::linux_setup: Sets up the users in Linux.

## Limitations

Tested with:
* MacOS 10.12 Sierra
* MacOS 10.11 El Capitan
* Ubuntu 16.04 Xenial
* Debian 8 Jessie

## Development

Any form of contribution is welcomed.

## Release Notes

0.1.0: First release