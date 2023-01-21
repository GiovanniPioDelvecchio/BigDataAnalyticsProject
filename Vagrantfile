Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.memory = "1024"
    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  end

  #config.vm.provision :shell, path: "bootstrap.sh"

  config.vm.define :master do |master|
    master.vm.box = "ubuntu/jammy64"
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "192.168.33.10"
    config.vm.provision :shell, inline: "echo Master"
    config.vm.provision :shell, path: "bootstrap.sh"
    config.vm.provision :shell, inline: "echo Master Ready and Bootstrapped"
  end

  %w{worker1 worker2}.each_with_index do |name, i|
    config.vm.define name do |worker|
      worker.vm.box = "ubuntu/jammy64"
      worker.vm.hostname = name
      worker.vm.network :private_network, ip: "10.0.0.#{i + 11}"
      config.vm.provision :shell, path: "bootstrap.sh"
      config.vm.provision :shell, inline: "echo worker #{i}"
    end
  end
end
