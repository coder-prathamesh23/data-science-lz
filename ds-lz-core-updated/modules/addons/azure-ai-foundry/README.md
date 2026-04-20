# Azure AI Foundry add-on module

This module creates Azure AI Foundry as a separate add-on for the Data Science Landing Zone.

## What it creates
- Azure AI Foundry resource
- Optional Foundry project
- Optional private endpoint for the Foundry resource

## What it does not create
- VNet
- subnets
- Private DNS zones

Those remain owned outside this module and are passed in as IDs.