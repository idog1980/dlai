New-Item -ItemType Directory -Name "my-repo"
Set-Location "my-repo"

$companies = @("dataloopAi", "idoAI", "michaelAI")
$environments = @("development", "staging", "production")
$cloudProviders = @("aws", "gcp")

# Create the common directory and subdirectories
New-Item -ItemType Directory -Path "common"
New-Item -ItemType Directory -Path "common\modules"
New-Item -ItemType Directory -Path "common\helm"
New-Item -ItemType Directory -Path "common\templates"

# Create a README file inside the common directory
New-Item -ItemType File -Path "common\README.md"

# Create a "1.txt" file in each common subdirectory
$commonSubdirectories = @("modules", "helm", "templates")

foreach ($subdir in $commonSubdirectories) {
    $subdirPath = Join-Path -Path "common" -ChildPath $subdir
    New-Item -ItemType File -Path $subdirPath -Name "1.txt"
}

# Create the company, environment, and cloud provider structure with a "1.txt" in each provider directory
foreach ($company in $companies) {
    foreach ($environment in $environments) {
        $envPath = Join-Path -Path $company -ChildPath "environment\$environment"
        New-Item -ItemType Directory -Path $envPath
        foreach ($provider in $cloudProviders) {
            $providerPath = Join-Path -Path $envPath -ChildPath $provider
            New-Item -ItemType Directory -Path $providerPath
            New-Item -ItemType Directory -Path (Join-Path -Path $providerPath -ChildPath "terraform")
            
            # Add a "1.txt" file to the current directory
            New-Item -ItemType File -Path $providerPath -Name "1.txt"
        }
    }
}

# Create a README file for the main repository
New-Item -ItemType File -Name "README.md"

Write-Host "Folder structure deployed successfully!"
