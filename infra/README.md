
# Infrastructure Overview

Infrastructure is configured using Terraform.

# Setup Instructions

> Get user credentials for Terraform: `make auth`
> After the below steps, follow instructions in
> [README-asm.md][1] to configure `Anthos Service Mesh`

```bash
make init
make build
make deploy
```

# Clean the Infrastructure

```bash
make undeploy
```

------------
[1]: ./README-asm.md