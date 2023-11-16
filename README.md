# Welcome to DataloopAI homework.
Hi, Thank you for the opportunity to submit the work.
Please read the following and note to understand the work.

TLDR - 
I look forward to discuss this work. there are many code files TF and like that is spread along the folder structure, they are left there on propose for the discussion.

# Compromises made
- Google Cloud - The work with google cloud and windows based computer was challenging. There as a lot of compromises that was needed to be done here , for example ``kubectl`` environment wasnt working with ``gcloud``. In addition I tested my assignments on a personal google account which has a lot of restrictions (i.e. number of projects per account ..)
- Security - Some security compromises were made, hardcoded security credentials login with gcloud to owner user and not create a service user to run the terraform.
- Production grade - Although the task clearly says to take in to account production grade elements, I was concentrating on K8s deployments as production grade and less other stuff. the large compromise here is **pipelines**, Almost everything done here can be automated via pipeline and I didn't go there due to the time element.


## Create files and folders assignment
Under the ``my-repo`` the structure of the folder can be found.
The script that creates it is ``structure.ps1`` as my home computer is windows based which proven to be a significant roadblock in the efforts to come

## GKE - Terraform
The Terraform deployment task uses a public module for GKE. Because of compromises mentioned some editing are necessary to made it work 
TF files are located in ``\dlai\my-repo\dataloopAi\environment\staging\gcp``

1. Please login to google cloud ``gcloud auth application-default login``
2. Create a project in google cloud 
3. Edit ``locals.tf`` with the desired zone and project_id
4. Edit the k8s.tf as you see fit, cluster name zones , machine sizes etc.

## GKE - Application Deployment
Once k8s is available, clone this repo.
Under ``\dlai\my-repo\dataloopAi\environment\staging\gcp\apps`` there is a python script that runs and install argoCD and add the relevant application.
1. make sure you have pip, kubectl and git installed on the environment. Since I worked on windows machine that is my personal gaming machine I didnt have those and used google dev machine to connect to it.
2. Run ``argocd_deployment.py`` 
3. login to ArgoCD or use kubectl to get the external IP's  


## Grafana Dashboard
For Grafana import the following Dashboard:
- Kubernetes Deployment Statefulset Daemonset metrics id : 8588 
- Nginx : 14900