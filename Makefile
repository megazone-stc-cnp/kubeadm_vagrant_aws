help:
	echo "\t\t\t\tvagrant_install: vagrant 설치"
	echo "\t\t\t\tplugin_install: plugin 설치"
	echo "\t\t\t\tstart : vagrant 실행"
	echo "\t\t\t\tssh : 서버에 접속"
	echo "\t\t\t\tstop: 중지"
	echo "\t\t\t\tdelete: 삭제"
	echo "\t\t\t\tclean: vagrant 제거"
	
vagrant_install:
	brew install hashicorp/tap/hashicorp-vagrant

plugin_install:
	vagrant plugin install vagrant-env
	vagrant plugin install vagrant-aws
	vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

up:
	aws s3 rm s3://cnp-key/token.join
	vagrant up --provider=aws

connect:
	vagrant ssh

.PHONY: ssh
ssh:
	vagrant ssh

.PHONY: destroy
destroy:
	vagrant destroy

.PHONY: delete
delete:
	vagrant destroy

.PHONY: status
status:
	vagrant status

.PHONY: start
start:
	vagrant resume

.PHONY: stop
stop:
	vagrant halt

.PHONY: clean	
clean:
	rm -rf .vagrant

.PHONY: encrypt
encrypt:
	ansible-vault encrypt .env

.PHONY: decrypt
decrypt:
	ansible-vault view .env.vault | tee .env
