# Azure AI Foundry add-on stack

This stack deploys Azure AI Foundry as a separate add-on on top of the DSLZ core stack.

## Inputs from core remote state
- location
- resource_group_name
- tags
- private_endpoints_subnet_id

## Inputs requested manually from Cloud Services
- private DNS zone IDs for Foundry private connectivity

## What it creates
- Azure AI Foundry resource
- Optional Foundry project
- Optional private endpoint for the Foundry resource

## What it does not create
- VNet
- subnets
- Private DNS zones
- DNS resource group references

Those remain outside this stack and are provided manually where needed.