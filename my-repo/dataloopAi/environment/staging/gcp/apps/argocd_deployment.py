import subprocess
import base64
import time
import json
from kubernetes import client, config

repo_url = "https://github.com/idog1980/dlai.git"

def install_pip_k8s():
    # Install the k8s pip module for python
    subprocess.run(["pip", "install", "kubernetes"], check=True)

def install_argo_cd():
    # Apply the argoCD installation YAML
    subprocess.run(["kubectl", "create", "namespace", "argocd"], check=True)
    subprocess.run(["kubectl", "apply", "-n", "argocd", "-f", "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"], check=True)

def patching_argocd_lb():
    patch_data = {"spec": {"type": "LoadBalancer"}}
    patch_data_str = json.dumps(patch_data)
    subprocess.run(["kubectl", "patch", "svc", "argocd-server", "-n", "argocd", "-p", patch_data_str])


def install_argo_cd_cli():
    # Adjust the command according to your OS and installation method
    subprocess.run(["sudo","curl", "-sSL", "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64", "-o", "/usr/local/bin/argocd"], check=True)
    subprocess.run(["sudo", "chmod", "+x", "/usr/local/bin/argocd"], check=True)

def echo_argo_cd_password():
    # Get the base64 encoded password
    encoded_password = subprocess.check_output(
        ["kubectl", "-n", "argocd", "get", "secret", "argocd-initial-admin-secret", "-o", "jsonpath={.data.password}"],
        text=True
    )

    # Decode the base64 encoded password
    decoded_password = base64.b64decode(encoded_password).decode('utf-8')
    print(f'The Argo CD password is: {decoded_password}')
    return decoded_password
    
def get_argocd_server_address(namespace="argocd"):
    config.load_kube_config()
    v1 = client.CoreV1Api()

    services = v1.list_namespaced_service(namespace)

    for service in services.items:
        if service.metadata.name == "argocd-server":
            for ingress in service.status.load_balancer.ingress:
                print(ingress.ip)
                print(ingress.hostname)
                return ingress.ip or ingress.hostname
    return None


def login_argo_cd(password):
    argocd_server = get_argocd_server_address()
    if argocd_server:
        print(f"Argo CD Server Address: {argocd_server}")
    else:
        print("Argo CD Server Address not found")
    # Login to Argo CD (replace ARGOCD_SERVER with your Argo CD server address)
    argocd_port = 80
    argocd_server_login = f"{argocd_server}:{argocd_port}"
    subprocess.run(["argocd", "login", argocd_server_login, "--username", "admin", "--password", password, "--insecure"], check=True)

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
        "--self-heal"
    ], check=True)

if __name__ == "__main__":
    config.load_kube_config()  # Load kube config

    # installing pip k8s
    install_pip_k8s()
    print("Installed pip kubernetes")
    
    # Install argoCD
    install_argo_cd()
    print("Installed argoCD")

    install_argo_cd_cli()
    print("Installed argoCD CLI")
    
    print("waiting 1 min for argoCD to finish deploying")
    time.sleep(60)

    print("Waiting 2 min for argoCD to patch to LoadBalancer")
    patching_argocd_lb()
    time.sleep(120)
    
    # Authenticate with argoCD
    argo_password = echo_argo_cd_password()
    login_argo_cd(argo_password)

    # apps to argoCD
    print("creating nginx")
    create_argo_cd_application("nginx", "my-repo/dataloopAi/environment/staging/gcp/apps/nginx", "services")
    print("creating prometheus")
    create_argo_cd_application("prometheus", "my-repo/dataloopAi/environment/staging/gcp/apps/prometheus", "monitoring")
    print("creating kube-state-metrics")
    create_argo_cd_application("kube-state-metrics", "my-repo/dataloopAi/environment/staging/gcp/apps/kube-state-metric", "kube-system")
    print("creating grafana")
    create_argo_cd_application("grafana", "my-repo/dataloopAi/environment/staging/gcp/apps/grafana", "monitoring")
