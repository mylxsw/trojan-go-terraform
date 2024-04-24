run:
	echo "nothing to run"

clean:
	rm -fr .terraform.lock.hcl .terraform terraform.tfstate terraform.tfstate.backup trojan.tar.gz

.PHONY: run clean