# Shared storage account add-on stack

This stack deploys a shared ADLS Gen2 storage account on top of the DSLZ core stack.

## Inputs from core remote state
- location
- resource_group_name
- tags
- private_endpoints_subnet_id

## Inputs requested manually from the networking team
- Blob private DNS zone ID
- DFS private DNS zone ID

## What it creates
- One HNS-enabled shared storage account
- Blob private endpoint
- DFS private endpoint

## What it does not create
- VNet
- subnets
- private DNS zones

Those remain outside this stack and are provided as existing IDs.