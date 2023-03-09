install:
	kubectl apply -f namespaces.yaml

install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://grafana.github.io/helm-charts
	helm repo update

	helm install -n monitoring -f prometheus/operator-values.yaml prometheus prometheus-community/kube-prometheus-stack
	
	kubectl apply -f prometheus/monitoring-nodeport.yaml

install-ingress:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
	helm repo update
	
	helm install nginx ingress-nginx/ingress-nginx --namespace ingress -f ingress/ingress.yaml