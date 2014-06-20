package :create_deploy_user, :provides => :deployer do
  description 'Create deploy user'

  requires :add_deploy_user, :add_deploy_ssh_keys, :set_permissions
end

package :add_deploy_user do
  description "Create the deploy user"

  sudoers = "/etc/sudoers"

  deploy_user = config(:DEPLOY_USER)
  deploy_user_password = config(:DEPLOY_USER_PASSWORD, :required => false)

  runner "useradd --create-home --shell /bin/bash --user-group --groups users,sudo #{deploy_user}"
  runner "echo '#{deploy_user}:#{deploy_user_password}' | chpasswd"
  runner "echo '#{deploy_user}\tALL=(ALL:ALL) NOPASSWD:ALL' | tee -a #{sudoers}"

  verify do
    has_directory "/home/#{deploy_user}"
  end
end

package :add_deploy_ssh_keys do
  description "Add deployer public key to authorized ones"
  requires :add_deploy_user

  deploy_user = config(:DEPLOY_USER)

  id_rsa_pub = `cat ~/.ssh/id_rsa.pub`
  authorized_keys_file = "/home/#{deploy_user}/.ssh/authorized_keys"

  push_text id_rsa_pub, authorized_keys_file do
    # Ensure there is a .ssh folder.
    pre :install, "mkdir -p /home/#{deploy_user}/.ssh"
  end

  verify do
#    file_contains authorized_keys_file, id_rsa_pub
   has_file authorized_keys_file
  end
end

package :set_permissions do
  description "Set correct permissions and ownership"
  requires :add_deploy_ssh_keys

  deploy_user = config(:DEPLOY_USER)

  runner "chmod 0700 /home/#{deploy_user}/.ssh"
  runner "chown -R #{deploy_user}:#{deploy_user} /home/#{deploy_user}/.ssh"
  runner "chmod 0700 /home/#{deploy_user}/.ssh/authorized_keys"
end
