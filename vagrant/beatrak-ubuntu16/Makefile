export VM_USER=beatrakker
export VM_NAME=beatrak-ubuntu16
# export EXTRA=yes # deploy some extra packages like emacs if defined

create:
	@echo "VM_USER="${VM_USER}
	@echo "VM_NAME="${VM_NAME}
	vagrant plugin install vagrant-disksize
	vagrant up
stop:
	vagrant halt
prov:
	vagrant provision
delete:
	vagrant destroy
ssh:
	vagrant ssh

shell:
	ssh -p 2222 ${VM_USER}@localhost
