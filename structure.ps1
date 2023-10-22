New-Item -ItemType Directory -Name "my-repo"
Set-Location "my-repo"

$companies = @("DataloopAI", "IdoAI", "MichaelAI")
$environments = @("development", "staging", "production")
$cloudProviders = @("aws", "gcp")

# Loop through companies and environments
foreach ($company in $companies) {
    foreach ($environment in $environments) {
        $envPath = Join-Path -Path $company -ChildPath "environment\$environment"
        New-Item -ItemType Directory -Path $envPath
        foreach ($provider in $cloudProviders) {
            $providerPath = Join-Path -Path $envPath -ChildPath $provider
            New-Item -ItemType Directory -Path $providerPath
            New-Item -ItemType Directory -Path (Join-Path -Path $providerPath -ChildPath "terraform")
        }
    }
}

New-Item -ItemType Directory -Path "common"
New-Item -ItemType Directory -Path "common\modules"
New-Item -ItemType Directory -Path "common\scripts"
New-Item -ItemType Directory -Path "common\templates"
New-Item -ItemType File -Path "common\README.md"

New-Item -ItemType File -Name "README.md"

Write-Host "Folder structure deployed successfully!"
