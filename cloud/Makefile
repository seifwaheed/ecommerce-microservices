.PHONY: help setup build deploy clean test

help:
	@echo "E-Commerce Microservices - Makefile Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup-kind      - Create KinD cluster"
	@echo "  make build           - Build all Docker images"
	@echo "  make load-images     - Load images into KinD"
	@echo "  make setup-argocd    - Install ArgoCD"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy          - Deploy all services"
	@echo "  make deploy-kafka    - Deploy Kafka only"
	@echo ""
	@echo "Development:"
	@echo "  make dev-catalog     - Run catalog service locally"
	@echo "  make dev-cart        - Run cart service locally"
	@echo "  make dev-order       - Run order service locally"
	@echo "  make dev-payment     - Run payment service locally"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           - Delete KinD cluster"
	@echo "  make clean-all       - Delete cluster and all resources"

setup-kind:
	@echo "Creating KinD cluster..."
	@if [ -f scripts/setup-kind.sh ]; then \
		chmod +x scripts/setup-kind.sh && ./scripts/setup-kind.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/setup-kind.ps1; \
	fi

build:
	@echo "Building Docker images..."
	docker build -t catalog-service:latest ./services/catalog
	docker build -t cart-service:latest ./services/cart
	docker build -t order-service:latest ./services/order
	docker build -t payment-service:latest ./services/payment
	docker build -t dashboard:latest ./dashboard

load-images:
	@echo "Loading images into KinD..."
	kind load docker-image catalog-service:latest --name ecommerce-cluster
	kind load docker-image cart-service:latest --name ecommerce-cluster
	kind load docker-image order-service:latest --name ecommerce-cluster
	kind load docker-image payment-service:latest --name ecommerce-cluster
	kind load docker-image dashboard:latest --name ecommerce-cluster

setup-argocd:
	@if [ -f scripts/setup-argocd.sh ]; then \
		chmod +x scripts/setup-argocd.sh && ./scripts/setup-argocd.sh; \
	else \
		powershell -ExecutionPolicy Bypass -File scripts/setup-argocd.ps1; \
	fi

deploy-kafka:
	@echo "Deploying Kafka..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f kafka/

deploy:
	@echo "Deploying all services..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f kafka/
	@echo "Waiting for Kafka..."
	@sleep 10
	kubectl apply -f k8s/

dev-catalog:
	cd services/catalog && pip install -r requirements.txt && uvicorn main:app --reload --port 8001

dev-cart:
	cd services/cart && pip install -r requirements.txt && uvicorn main:app --reload --port 8002

dev-order:
	cd services/order && pip install -r requirements.txt && uvicorn main:app --reload --port 8003

dev-payment:
	cd services/payment && pip install -r requirements.txt && uvicorn main:app --reload --port 8004

clean:
	@echo "Deleting KinD cluster..."
	kind delete cluster --name ecommerce-cluster

clean-all: clean
	@echo "Cleaning up Kubernetes resources..."
	kubectl delete namespace ecommerce --ignore-not-found=true
	kubectl delete namespace argocd --ignore-not-found=true

test:
	@echo "Running tests..."
	@echo "Add your test commands here"

