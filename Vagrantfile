class Hash
  def slice(*keep_keys)
    h = {}
    keep_keys.each { |key| h[key] = fetch(key) if has_key?(key) }
    h
  end unless Hash.method_defined?(:slice)
  def except(*less_keys)
    slice(*keys - less_keys)
  end unless Hash.method_defined?(:except)
end

Vagrant.configure("2") do |config|
  config.env.enable
  access_key = ENV['ACCESS_KEY']
  secret_key = ENV['SECRET_KEY']
  key_path = ENV['KEY_PATH']
  key_name = ENV['KEY_NAME']
  region = ENV['REGION']
  security_group = ENV['SECURITY_GROUP']
  ami_name = ENV['ANE2_UBUNTU_IMAGE']
  master_ip = ENV['MASTER_IP']
  node1_ip = ENV['NODE1_IP']
  node2_ip = ENV['NODE2_IP']
  az_zone = ENV['AZ_ZONE']
  s3_bucket_path = ENV['S3_BUCKET_PATH']

  config.vm.define "master" do |master|
    master.vm.box = "dummy"
    master.vm.hostname = "master"
    master.vm.provider :aws do |aws, override|
      aws.access_key_id = access_key
      aws.secret_access_key = secret_key
      aws.keypair_name = key_name

      aws.ami = ami_name
      aws.region = region
      aws.instance_type = "t3.medium"
      aws.security_groups = [security_group]
      aws.private_ip_address = master_ip
      aws.availability_zone = az_zone
      aws.block_device_mapping = [  {    'DeviceName' => '/dev/xvda',    'Ebs.VolumeSize' => 100,    'Ebs.VolumeType' => 'gp2'  }]
      aws.tags = {
        'Name' => 'master'
      }

      master.vm.synced_folder '.', '/vagrant', disabled: true

      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = key_path + "/" + key_name + ".pem"
    end
    master.vm.provision "shell", path: "ubuntu_commons.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path, "NODE_NAME" => "master"}
    master.vm.provision "shell", path: "bootstrap_master.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path}
  end

  config.vm.define "node1" do |node1|
    node1.vm.box = "dummy"
    node1.vm.hostname = "node1"
    node1.vm.provider :aws do |aws, override|
      aws.access_key_id = access_key
      aws.secret_access_key = secret_key

      aws.keypair_name = key_name

      aws.ami = ami_name
      aws.region = region
      aws.instance_type = "t3.medium"
      aws.security_groups = [security_group]
      aws.private_ip_address = node1_ip
      aws.availability_zone = az_zone
      aws.block_device_mapping = [  {    'DeviceName' => '/dev/xvda',    'Ebs.VolumeSize' => 100,    'Ebs.VolumeType' => 'gp2'  }]
      aws.tags = {
        'Name' => 'node1'
      }

      node1.vm.synced_folder '.', '/vagrant', disabled: true

      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = key_path + "/" + key_name + ".pem"
    end
    node1.vm.provision "shell", path: "ubuntu_commons.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path, "NODE_NAME" => "node1"}
    node1.vm.provision "shell", path: "bootstrap_node1.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path}
  end

  config.vm.define "node2" do |node2|
    node2.vm.box = "dummy"
    node2.vm.hostname = "node2"
    node2.vm.provider :aws do |aws, override|
      aws.access_key_id = access_key
      aws.secret_access_key = secret_key

      aws.keypair_name = key_name

      aws.ami = ami_name
      aws.region = region
      aws.instance_type = "t3.medium"
      aws.security_groups = [security_group]
      aws.private_ip_address = node2_ip
      aws.availability_zone = az_zone
      aws.block_device_mapping = [  {    'DeviceName' => '/dev/xvda',    'Ebs.VolumeSize' => 100,    'Ebs.VolumeType' => 'gp2'  }]
      aws.tags = {
        'Name' => 'node2'
      }

      node2.vm.synced_folder '.', '/vagrant', disabled: true

      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = key_path + "/" + key_name + ".pem"
    end
    node2.vm.provision "shell", path: "ubuntu_commons.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path, "NODE_NAME" => "node2"}
    node2.vm.provision "shell", path: "bootstrap_node2.sh", env: {"ACCESS_KEY" => access_key, "SECRET_KEY" => secret_key, "KEY_NAME" => key_name, "REGION" => region, "MASTER_IP" => master_ip, "NODE1_IP" => node1_ip, "NODE2_IP" => node2_ip, "S3_BUCKET_PATH" => s3_bucket_path}
  end
end