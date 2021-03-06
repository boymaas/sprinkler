package :redis do
  requires :redis_preliminaries, :redis_build
end

package :redis_build do
  requires :redis_preliminaries

  source "http://download.redis.io/releases/redis-2.8.9.tar.gz" do
    pre :install, "killall -9 redis-server || true"
    post :install, 'cd utils && ( echo | ./install_server.sh )'
    custom_install "make install"
  end

  verify do
    has_executable 'redis-server'
    has_executable '/etc/init.d/redis_6379'
    has_executable_with_version('redis-server', '2.8.9', '--version')

    #has_file '/etc/init.d/redis'
    #has_process 'redis'
  end
end

package :redis_preliminaries do
  apt %w(build-essential tcl8.5)

  runner %w(apt-get remove -y redis-server)

  verify do
    has_apt "tcl8.5"
    has_apt "build-essential"
  end
end
