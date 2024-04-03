# Install the Persistence Sniper module without confirmation prompts
Install-Module -Name PersistenceSniper -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck -Verbose *> $null

# Import the Persistence Sniper module
Import-Module -Name PersistenceSniper -Force