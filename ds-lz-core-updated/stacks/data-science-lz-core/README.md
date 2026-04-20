# Stack: data-science-lz-core

This stack deploys the base Data Science landing zone.

## What it deploys
- landing zone resource group protected by default
- spoke VNet and the required subnets when `network_mode = "create"`
- references existing VNet and subnets when `network_mode = "import"`
- optional shared baseline resources needed for the subscription
- vHub connection to the hub Virtual Hub when enabled

## What it does not deploy
- Azure Machine Learning workspace
- Private DNS zones
- Private DNS zone virtual network links
- AML private endpoints

Those stay with the AML add-on or with Cloud Services depending on ownership.

## Notes
- the private endpoints subnet always disables private endpoint network policies when the subnet is created by this stack
- custom DNS servers are optional and should only be set when Cloud Services provides the central DNS forwarder / resolver IPs
- the stack outputs all IDs needed by the AML add-on
