import subprocess
import base64
import time
from kubernetes import client, config

repo_url = "https://github.com/idog1980/dlai.git"

def install_pip_k8s():
    # Install the k8s pip module for python
    subprocess.run(["pip", "install", "kubernetes"], check=True)

def install_argo_cd():
    # Apply the argoCD installation YAML
    subprocess.run(["kubectl", "create", "namespace", "argocd"], check=True)
    subprocess.run(["kubectl", "apply", "-n", "argocd", "-f", "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"], check=True)

def install_argo_cd_cli():
    # Adjust the command according to your OS and installation method
    subprocess.run(["sudo","curl", "-sSL", "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64", "-o", "/usr/local/bin/argocd"], check=True)
    subprocess.run(["sudo", "chmod", "+x", "/usr/local/bin/argocd"], check=True)

def get_argo_cd_password():
    # Get argoCD server password
    password = subprocess.check_output(["kubectl", "-n", "argocd", "get", "secret", "argocd-initial-admin-secret", "-o", "jsonpath={.data.password}"], text=True)
    return password

def echo_argo_cd_password():
    # Get the base64 encoded password
    encoded_password = subprocess.check_output(
        ["kubectl", "-n", "argocd", "get", "secret", "argocd-initial-admin-secret", "-o", "jsonpath={.data.password}"],
        text=True
    )

    # Decode the base64 encoded password
    decoded_password = base64.b64decode(encoded_password).decode('utf-8')
    print(f'The Argo CD password is: {decoded_password}')
    
def get_argocd_server_address(namespace="argocd"):
    # Load kubeconfig and initialize Kubernetes client
    config.load_kube_config()
    v1 = client.CoreV1Api()

        # Get the list of services in the specified namespace
    services = v1.list_namespaced_service(namespace)

    for service in services.items:
        if service.metadata.name == "argocd-server":
        # Assuming LoadBalancer service type
            for ingress in service.status.load_balancer.ingress:
                return ingress.ip or ingress.hostname

    return None


def login_argo_cd(password):
    argocd_server = get_argocd_server_address()
    if argocd_server:
        print(f"Argo CD Server Address: {argocd_server}")
    print("Argo CD Server Address not found")
    # Login to Argo CD (replace ARGOCD_SERVER with your Argo CD server address)
    subprocess.run(["argocd", "login", argocd_server, "--username", "admin", "--password", password], check=True)

def create_argo_cd_application(app_name, path, namespace):
    # Create an argoCD applications
    subprocess.run([
        "argocd", "app", "create", app_name,
        "--repo", repo_url,
        "--path", path,
        "--dest-server", "https://kubernetes.default.svc",
        "--dest-namespace", namespace,
        "--sync-policy", "automated",
        "--auto-prune",
        "--auto-create-namespace",
        "--self-heal"
    ], check=True)

if __name__ == "__main__":
    config.load_kube_config()  # Load kube config

    # installing pip k8s
    install_pip_k8s()
    
    # Install argoCD
    install_argo_cd()

    # Install argoCD CLI
    install_argo_cd_cli()

    # Wait for argoCD components to be ready
    time.sleep(120)

    # Echo argoCD password
    echo_argo_cd_password()
    
    # Authenticate withargoCD
    argo_password = get_argo_cd_password()
    login_argo_cd(argo_password)

    # apps to argoCD
    create_argo_cd_application("nginx", repo_url, "my-repo/dataloopAi/environment/staging/gcp/apps/nginx", "services")
    create_argo_cd_application("prometheus", repo_url, "my-repo/dataloopAi/environment/staging/gcp/apps/prometheus", "monitoring")
    create_argo_cd_application("kube-state-metrics", repo_url, "my-repo/dataloopAi/environment/staging/gcp/apps/kube-state-metric", "kube-system")
    create_argo_cd_application("grafana", repo_url, "my-repo/dataloopAi/environment/staging/gcp/apps/grafana", "monitoring")
