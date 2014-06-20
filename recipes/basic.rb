load_packages :create_deploy_user

policy :basic, :roles => :recipes_target do
  requires :create_deploy_user
end
