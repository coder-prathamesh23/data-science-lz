# Managed DevOps Pool add-on module

This module creates:
- a Dev Center
- a Dev Center Project
- a Managed DevOps Pool

## What it consumes from core
- resource_group_name
- location
- tags
- managed_devops_pool_subnet_id

## What it does not create
- VNet
- shared DNS zones
- private endpoints

The pool agents are injected into a delegated subnet in the existing landing-zone VNet.