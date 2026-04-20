# Managed DevOps Pool add-on stack

This stack deploys:
- a Dev Center
- a Dev Center Project
- a Managed DevOps Pool

## Inputs from core remote state
- location
- resource_group_name
- tags
- managed_devops_pool_subnet_id

## What this stack does not create
- VNet
- shared DNS zones
- private endpoints

The pool agents are injected into the delegated subnet created by the core stack.