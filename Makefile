install:
	kubectl apply -f namespaces.yaml

install-all: install install-istio install-cert-manager install-jaeger install-prometheus install-kiali

install-istio:
	istioctl install --set profile=default -y
	istioctl operator init --watchedNamespaces istio-system --operatorNamespace istio-operator
	
	kubectl apply -f istio/istio.yaml
	kubectl apply -f istio/disable-mtls.yaml

install-cert-manager:
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install \
		--namespace cert-manager \
		--create-namespace \
		--set installCRDs=true \
		cert-manager \
		jetstack/cert-manager

install-jaeger: 
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	helm repo update
	helm install -n jaeger-operator -f jaeger/operator-values.yaml jaeger-operator jaegertracing/jaeger-operator

	kubectl apply -f jaeger/jaeger.yaml

install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://grafana.github.io/helm-charts
	helm repo update

	helm install -n monitoring -f prometheus/operator-values.yaml prometheus prometheus-community/kube-prometheus-stack
	
	kubectl apply -f prometheus/monitoring-nodeport.yaml

# minikube service -n monitoring prom-prometheus-nodeport
# minikube service -n monitoring prometheus-grafana-nodeport

install-kiali:
	helm repo add kiali https://kiali.org/helm-charts
	helm repo update

	helm install \
		--set cr.create=true \
    	--set cr.namespace=istio-system \
		--namespace kiali-operator \
		-n kiali-operator \
		-f kiali/operator-values.yaml \
		kiali-operator \
		kiali/kiali-operator 

	kubectl apply -f kiali/kiali.yaml

# minikube service -n kiali kiali-nodeport
# kubectl get po -n kiali -l app.kubernetes.io/name=kiali

minikube-tunnel:
	minikube tunnel

docker-build:
	docker build --platform linux/amd64 -t docker.io/amburskui/echoserver:v0.1 --build-arg VERSION=v0.1 -f app/src/Dockerfile app/src	docker build --platform linux/amd64 -t docker.io/amburskui/echoserver:v0.2 --build-arg VERSION=v0.2 -f app/src/Dockerfile app/src

docker-push:
	docker push docker.io/amburskui/echoserver:v0.1
	docker push docker.io/amburskui/echoserver:v0.2