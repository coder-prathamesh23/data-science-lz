# Shared storage account add-on module

This module creates a shared ADLS Gen2 storage account intended to be used by both Azure Machine Learning and Microsoft Fabric.

## What it creates
- One HNS-enabled Azure Storage Account
- Optional Blob private endpoint
- Optional DFS private endpoint

## What it does not create
- VNets
- subnets
- private DNS zones

Those stay outside this add-on and are provided as existing IDs.