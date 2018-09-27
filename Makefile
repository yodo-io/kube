HELM_VERSION ?= v2.11.0
HELM_PLATFORM ?= darwin-amd64

HELM ?= $(PWD)/bin/helm

KUBECTX ?= $(shell kubectl config current-context)

bin:
	mkdir bin

tf-output:
	tf apply

bin/helm: bin
	curl https://storage.googleapis.com/kubernetes-helm/helm-$(HELM_VERSION)-$(HELM_PLATFORM).tar.gz > helm-$(HELM_VERSION)-$(HELM_PLATFORM).tar.gz
	tar xzf helm-$(HELM_VERSION)-$(HELM_PLATFORM).tar.gz
	mv $(HELM_PLATFORM)/helm bin/
	rm -rf $(HELM_PLATFORM) helm-$(HELM_VERSION)-$(HELM_PLATFORM).tar.gz
	chmod +x bin/helm

bootstrap: bin/helm
	HELM=$(HELM) CONTEXT=$(KUBECTX) ./modules/bootstrap/charts.sh

bootstrap-vault: tf-output bin/helm
	HELM=$(HELM) CONTEXT=$(KUBECTX) ./output/vault/vault.sh

clean:
	rm -rf tf-output
