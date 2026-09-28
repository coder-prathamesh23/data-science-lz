# AI Landing Zone and Workload IaC Architecture

## Purpose

This document explains the architectural purpose of the two Terraform repositories used for the Azure AI platform, how the repositories are connected, how workload deployments consume infrastructure created by the AI Landing Zone, and how Terraform state is handled for each repository.

The two repositories are hosted in separate Azure DevOps projects:

- **AILZ repository** — Azure DevOps project: **Cloud Services - Azure - AILZ**
- **IaC repository** — Azure DevOps project: **ArtificialIntelligence**

The description below is based on the AILZ and IaC repository code reviewed. It distinguishes between capabilities that are defined in code and resources that are demonstrably consumed by the workload stacks. It does not assume that every optional capability present in the AILZ module is enabled in every environment.

> **Architectural summary:** The AILZ repository establishes the AI landing-zone and shared platform foundation. The IaC repository deploys shared application components and workload-specific Azure services on top of that foundation. The two repositories have separate Terraform state lifecycles and are connected through deployed Azure resource IDs, names, and runtime discovery rather than through shared Terraform state.

---

## 1. Architecture at a Glance

![AILZ and IaC repository relationship](ailz_and_iac_repository_relationship_with_state.png)

*Figure 1. AILZ provides the platform foundation; the IaC repository consumes existing platform resources and deploys workload-specific services. Terraform state is kept separately for the two repository layers.*

> **Diagram note:** The AILZ side represents capabilities defined by the landing-zone Terraform configuration. Some definitions are controlled by deployment flags. Their presence in `main.tf` does not, by itself, prove that every capability is enabled in every environment.

---

## 2. Repository Responsibilities and Boundaries

| Layer | Azure DevOps Project | Primary Purpose | Terraform State Boundary |
|---|---|---|---|
| **AI Landing Zone** | `Cloud Services - Azure - AILZ` | Landing-zone networking, hub connectivity, Private DNS integration, shared platform capabilities, and AI platform definitions | AzureRM remote backend |
| **Workload IaC** | `ArtificialIntelligence` | Workload-specific and shared application Terraform stacks, executed through root-level Azure DevOps pipelines | Primarily local state during pipeline execution, with Azure DevOps artifact-based persistence for specific stacks |

The repositories have intentionally different responsibilities.

The **AILZ repository** establishes the platform environment that downstream workloads can consume. This includes the network foundation and the broader set of shared and AI platform capabilities represented by the Azure AI and Machine Learning Landing Zone module.

The **IaC repository** does not recreate that landing-zone foundation. It contains individual workload and shared-service Terraform stacks, each driven by a corresponding Azure DevOps pipeline. Where a workload needs an AILZ resource, the IaC pipeline supplies the existing Azure resource ID or name to the Terraform stack.

No cross-repository `terraform_remote_state` dependency was identified in the reviewed IaC code. The workload repository does **not** read the AILZ Terraform state file to obtain VNet, subnet, Key Vault, or DNS values.

---

# 3. AI Landing Zone Repository

## 3.1 Purpose of the AILZ Repository

The AILZ repository represents the AI landing-zone platform layer. It is broader than a network-only repository.

The principal Terraform configuration in `main.tf` uses the Azure Verified Module for the Azure AI and Machine Learning Landing Zone:

`Azure/avm-ptn-aiml-landing-zone/azurerm`

The module block is named `test` in the Terraform code. This is only the Terraform logical module label; it does not change the architectural purpose of the module.

The AILZ configuration provides the common platform context within which downstream workloads operate. For the current IaC integration, the most important capabilities are the landing-zone VNet and subnet structure, hub connectivity, Private DNS integration, and shared services such as Key Vault.

The same module configuration contains definitions for additional AI and shared platform services. These definitions demonstrate what the landing-zone configuration supports; their actual deployment remains dependent on the configuration and deployment flags used for the environment.

## 3.2 Key AILZ Files

| File | Purpose |
|---|---|
| `azure-pipelines.yml` | AILZ Azure DevOps pipeline entry point |
| `cd_ai_landingzone.yaml` | Connects the repository to the centralized deployment template used for the landing-zone deployment |
| `terraform.tf` | Terraform/provider configuration and the active AzureRM backend declaration |
| `local.tf` | Naming, subscription/platform references, hub/DNS context, and other shared local values |
| `main.tf` | Main Azure AI and ML Landing Zone module configuration |
| `variables.tf` | Root input variables |
| `vwan_hub_peering.tf` | Virtual WAN hub connection for the landing-zone VNet |

## 3.3 AILZ Capabilities Defined in `main.tf`

### Networking and Connectivity

The reviewed AILZ configuration contains definitions for the landing-zone and connectivity layer, including:

- Resource group and landing-zone naming
- Virtual Network
- Subnets
- Network-related references and controls
- Private DNS integration
- Virtual WAN hub connectivity
- Bastion
- Application Gateway
- Application Gateway backend address pools
- Application Gateway backend HTTP settings
- Frontend ports
- HTTP listeners
- Request-routing configuration
- API Management related configuration

The separate `vwan_hub_peering.tf` file defines the connection between the AILZ VNet and the existing Virtual WAN hub. This means individual workload stacks do not need to implement their own hub connection.

### AI and Data Platform Definitions

The AILZ module configuration also contains definitions for:

- AI Foundry
- AI model deployments
- AI projects
- AI Search
- Cosmos DB

These are platform-level definitions inside AILZ. They should not automatically be treated as the same resources as workload-specific services of the same Azure service type in the IaC repository. For example, the GRC AI Search Terraform stack has its own resource naming and Terraform lifecycle.

### Shared and GenAI Platform Definitions

The AILZ configuration additionally contains definitions for services including:

- Key Vault
- Log Analytics Workspace
- Storage Account
- Container Apps Environment
- GenAI Container Registry
- GenAI Cosmos DB
- GenAI Key Vault
- Additional GenAI supporting-service definitions represented in the module configuration

Again, a definition being present in `main.tf` does not mean that the component is enabled in every environment.

---

# 4. Workload IaC Repository

## 4.1 Purpose of the IaC Repository

The IaC repository in the `ArtificialIntelligence` Azure DevOps project is the workload deployment layer.

Its root contains the Azure DevOps pipeline YAML files. Each workload pipeline points to the Terraform folder that defines the corresponding Azure resources. The repository also contains shared pipeline templates and the landing-zone smoke-test Terraform under `tests/lz-smoke`.

The IaC stacks generally assume that foundational resource groups and platform networking already exist. The stacks create and manage the application or workload resources inside those existing boundaries.

## 4.2 Pipeline-to-Terraform Mapping

| Root-Level Azure DevOps Pipeline | Terraform Folder | Primary Responsibility |
|---|---|---|
| `azure-pipelines-shared-app-service-dev.yml` | `shared-app-service/` | Shared App Service Plan and conditional Function App capability |
| `azure-pipelines-shared-app-insights-dev.yml` | `shared-app-insights/` | Application Insights and create-or-adopt Log Analytics Workspace behavior |
| `azure-pipelines-grc-function-app-dev.yml` | `grc-function-app/` | GRC Linux Function App, managed identity, optional VNet integration, optional Private Endpoint, and Application Insights support |
| `azure-pipelines-grc-ai-search-dev.yml` | `grc-ai-search/` | GRC Azure AI Search service, workload Private Endpoint, Private DNS association, and brownfield adoption logic |
| `azure-pipelines-easement-document-intelligence-dev.yml` | `easement-document-intelligence/` | Document Intelligence account, Key Vault secret handling, and prepared private-networking inputs |
| `azure-pipelines-foundation-ADF-dev.yml` | `foundation-adf-pipeline/` | Azure Data Factory baseline: Data Factory, integration runtime, linked services, datasets, and copy pipeline |
| `azure-pipelines-lz-terraform-smoke.yml` | `tests/lz-smoke/` plus the landing-zone validation context | Landing-zone validation and canary create/destroy |
| `azure-pipelines-sp-permissions-check.yml` | No workload Terraform folder | Service-principal control-plane and Storage data-plane permission validation |

The common tooling templates are:

- `templates/ensure-az-cli.yml`
- `templates/bootstrap-terraform.yml`

`templates/ensure-az-cli.yml` ensures Azure CLI is available on the agent.

`templates/bootstrap-terraform.yml` installs or reuses the Terraform version requested by the calling pipeline.

---

# 5. How the IaC Repository Refers to AILZ Resources

## 5.1 Integration Model

This is the most important relationship between the repositories.

The IaC repository does **not** obtain AILZ resource information by reading AILZ Terraform state.

Instead, the relationship works at the Azure resource layer:

1. AILZ creates or configures a platform resource.
2. The deployed resource has an Azure resource ID and resource name.
3. The IaC workload pipeline receives the existing resource ID or name as a pipeline variable, or discovers required information at runtime through Azure CLI.
4. The pipeline passes that value into the workload Terraform stack.
5. The workload Terraform creates only the workload-owned resource that consumes the existing platform resource.

This gives the repositories independent Terraform state while still providing an explicit integration contract.

---

## 5.2 GRC Function App: AILZ Private Endpoint Subnet Reference

### Platform Definition

The landing-zone VNet and subnet structure are defined through the AILZ module in:

`main.tf`

The broader hub connectivity is represented in:

`vwan_hub_peering.tf`

### Where the IaC Pipeline Refers to AILZ

The direct reference is in:

`azure-pipelines-grc-function-app-dev.yml`

The pipeline variable `PE_SUBNET_ID` contains the full Azure resource ID of the existing `PrivateEndpointSubnet` in the AILZ VNet.

The current Dev pipeline also contains `VNET_INTEGRATION_SUBNET_ID`, but in the supplied YAML that value is empty. The confirmed active AILZ network reference in this pipeline is therefore the Private Endpoint subnet.

During the Terraform plan command, the pipeline maps `PE_SUBNET_ID` to the Terraform variable:

`private_endpoint_subnet_id`

### Where Terraform Consumes the Reference

The variable is declared in:

`grc-function-app/variables.tf`

The value is consumed in:

`grc-function-app/main.tf`

The Function App Private Endpoint uses the supplied existing subnet through:

`subnet_id = var.private_endpoint_subnet_id`

The architectural boundary is therefore:

> **AILZ owns the VNet and subnet. The GRC Function App stack owns the Function App and its workload-specific Private Endpoint.**

### Application Insights Note

The Function App Terraform supports lookup and linkage to an existing Application Insights instance. The pipeline defines Application Insights name and resource-group variables. However, in the specific `terraform plan` command supplied in the reviewed `azure-pipelines-grc-function-app-dev.yml`, those Application Insights variables are not passed as explicit `-var` arguments. The module capability and the current pipeline wiring should therefore be treated separately.

---

## 5.3 GRC AI Search: AILZ Network and Private DNS Integration

The GRC AI Search deployment provides the clearest end-to-end example of AILZ-to-IaC integration.

### Platform Definition

The landing-zone network is defined through:

`AILZ/main.tf`

The AILZ hub connection is defined in:

`AILZ/vwan_hub_peering.tf`

The AILZ configuration also carries the platform context for Private DNS integration.

### Where the IaC Pipeline Refers to AILZ

The workload pipeline is:

`azure-pipelines-grc-ai-search-dev.yml`

The pipeline variable `PE_SUBNET_ID` contains the full Azure resource ID for the existing AILZ `PrivateEndpointSubnet`.

That value is passed into Terraform as:

`private_endpoint_subnet_id`

The same pipeline performs runtime Private DNS discovery. If a Search Private Endpoint already exists, the pipeline reads the Private Endpoint DNS configuration, determines the relevant Search Private DNS zone information, resolves the Private DNS zone resource ID, and supplies the result to Terraform through:

`private_dns_zone_ids`

### Where Terraform Consumes the References

The input variables are declared in:

`grc-ai-search/variables.tf`

The values are consumed in:

`grc-ai-search/main.tf`

The Search Private Endpoint uses:

`subnet_id = var.private_endpoint_subnet_id`

The Private DNS zone group uses:

`var.private_dns_zone_ids`

The ownership boundary is:

> **AILZ owns the landing-zone network and shared DNS platform. The GRC AI Search stack owns the workload Search service, its Private Endpoint, and the association of that endpoint with the supplied DNS zone IDs.**

### Brownfield Adoption

`azure-pipelines-grc-ai-search-dev.yml` also handles existing resources before planning.

The pipeline:

- Checks global Search name availability
- Searches accessible subscriptions for an existing Search service with the requested name
- Imports an existing Search service into local Terraform state when required
- Checks for an existing Search Private Endpoint
- Imports the existing Private Endpoint when required
- Performs DNS discovery before Terraform plan

This is workload adoption logic. It does not change ownership of the underlying AILZ subnet.

---

## 5.4 Easement Document Intelligence: AILZ Key Vault and Prepared Network Reference

The workload pipeline is:

`azure-pipelines-easement-document-intelligence-dev.yml`

The workload Terraform folder is:

`easement-document-intelligence/`

### Existing Key Vault Reference

The pipeline supplies an existing Key Vault resource ID through its Key Vault configuration.

The corresponding Terraform input is defined in:

`easement-document-intelligence/variables.tf`

The value is consumed in:

`easement-document-intelligence/main.tf`

When `save_keys_to_kv` is enabled and a Key Vault ID is supplied, the Terraform creates Key Vault secret resources for the Document Intelligence service keys in the **existing Key Vault** rather than creating a workload-specific Key Vault.

This is a direct shared-platform dependency.

### Private Endpoint Subnet Reference

The pipeline also carries `PE_SUBNET_ID` for the existing landing-zone Private Endpoint subnet.

However, the reviewed Private Endpoint and Private DNS Terraform blocks in `easement-document-intelligence/main.tf` are currently commented/disabled.

The correct architectural statement is therefore:

> **The Easement deployment is configured with the existing landing-zone Private Endpoint subnet as an available input, but the supplied Terraform does not currently activate the Easement Private Endpoint block.**

This distinction avoids describing a prepared integration point as an actively deployed resource.

---

## 5.5 IaC Stacks Without a Confirmed Direct AILZ Resource-ID Dependency

### Shared App Service

Pipeline:

`azure-pipelines-shared-app-service-dev.yml`

Terraform:

`shared-app-service/`

The stack primarily establishes the shared App Service Plan. The supplied Dev configuration does not show the same direct AILZ subnet or Key Vault dependency as the GRC workloads above.

### Shared App Insights

Pipeline:

`azure-pipelines-shared-app-insights-dev.yml`

Terraform:

`shared-app-insights/`

This stack manages Application Insights and the Log Analytics Workspace create-or-adopt behavior. No direct AILZ resource ID is required by the reviewed pipeline/module configuration.

### Foundation ADF

Pipeline:

`azure-pipelines-foundation-ADF-dev.yml`

Terraform:

`foundation-adf-pipeline/`

The current stack creates the Data Factory, Azure integration runtime, linked services, datasets, and the copy pipeline. The supplied Terraform does not show the same direct AILZ VNet, subnet, or Key Vault resource-ID dependency that is present in GRC Function App, GRC AI Search, and Easement.

---

# 6. Terraform State Architecture

## 6.1 State Is Not Shared Between AILZ and IaC

The AILZ and IaC repositories have independent Terraform state lifecycles.

The workload pipelines do not download, read, or modify the AILZ state file.

> **AILZ state describes the landing-zone/platform resources. IaC state describes the workload-owned resources. The integration between them is through deployed Azure resource references, not through shared Terraform state.**

---

## 6.2 AILZ Terraform State

### Backend Declaration

The active AILZ backend is declared in:

`terraform.tf`

The Terraform configuration contains an AzureRM backend declaration:

```hcl
backend "azurerm" {}
```

### Where the AILZ State Is Stored

An `azurerm` Terraform backend stores state remotely in **Azure Storage Blob Storage**.

The exact backend coordinates, such as the backend resource group, storage account, container, and state key, are **not hard-coded in the AILZ Terraform files reviewed**.

The repository delegates the deployment through:

- `azure-pipelines.yml`
- `cd_ai_landingzone.yaml`

and the centralized deployment template referenced by that pipeline configuration. Therefore, the exact Azure Storage backend coordinates are supplied outside the root Terraform backend block, through the deployment configuration/template used during Terraform initialization.

This document intentionally does not invent an Azure Storage account or container name that is not visible in the supplied repository code.

### How Plan Reads AILZ State

During an AILZ Terraform run:

1. The deployment initializes Terraform against the configured AzureRM backend.
2. Terraform retrieves the current remote state from Azure Storage.
3. Terraform evaluates the desired AILZ configuration against the current state and Azure resources.
4. Terraform generates the plan.

Conceptually:

**AILZ code → Terraform init → AzureRM backend → current remote state → Terraform plan**

### How Apply Updates AILZ State

Apply uses the same initialized backend and the same state lineage.

After Terraform changes the Azure resources, the updated Terraform state is written back to the AzureRM backend.

Conceptually:

**remote AILZ state → Terraform apply → Azure resource changes → updated state written back to Azure Storage**

---

# 7. IaC Terraform State

## 7.1 The IaC Repository Does Not Use One Identical State Pattern for Every Workload

The workload repository primarily uses local Terraform state during pipeline execution, but persistence differs between pipelines.

The explicit cross-run Azure DevOps state-artifact pattern is present in:

- `azure-pipelines-shared-app-service-dev.yml`
- `azure-pipelines-shared-app-insights-dev.yml`
- `azure-pipelines-grc-function-app-dev.yml`

GRC AI Search and Easement carry local state with their Plan-to-Apply bundles, but the supplied YAML does not show the same separate post-Apply state publication.

Foundation ADF does not show durable cross-run Terraform state persistence in the supplied pipeline.

The landing-zone smoke pipeline is a separate exception and uses an AzureRM backend.

## 7.2 State Behavior by Pipeline

| Pipeline | How Plan Gets State | Plan-to-Apply Handoff | Cross-Run State After Apply |
|---|---|---|---|
| `azure-pipelines-shared-app-service-dev.yml` | Searches prior successful runs for the configured tfstate artifact and restores it when available | Saved plan and local state are bundled for Apply | Updated state is published as an Azure DevOps Pipeline Artifact |
| `azure-pipelines-shared-app-insights-dev.yml` | Restores the previous state artifact when available | Saved plan and state are handed to Apply through artifacts | Updated state is published for subsequent runs |
| `azure-pipelines-grc-function-app-dev.yml` | `ProbeSeedRun` locates `tfstate-grc-function-app`; the state is downloaded and copied to `grc-function-app/terraform.tfstate` | `tfbundle.tgz` carries the saved plan and local state from Plan to Apply | Apply copies the resulting state to `statefiles/grc-function-app` and publishes `tfstate-grc-function-app` |
| `azure-pipelines-grc-ai-search-dev.yml` | Uses local state created or updated during discovery/import and plan; backend is disabled | `grc-aisearch-tf-artifact` carries the saved plan and state when present | No separate post-Apply final-state artifact publication is visible in the supplied YAML |
| `azure-pipelines-easement-document-intelligence-dev.yml` | Uses local state; an existing Document Intelligence account can be imported before plan | `di-tf-artifact` carries the saved plan and local state between Plan and Apply | No separate post-Apply final-state artifact publication is visible in the supplied YAML |
| `azure-pipelines-foundation-ADF-dev.yml` | Plan runs in the pipeline execution context | The pipeline publishes a saved `tfplan` | No persistent remote backend or post-Apply tfstate artifact is visible in the supplied YAML |
| `azure-pipelines-lz-terraform-smoke.yml` | Uses an AzureRM backend with the backend values supplied by the smoke pipeline | Remote backend provides state continuity | State persists through AzureRM backend state keys rather than workload state artifacts |

---

## 7.3 Detailed Artifact-Based State Flow

The clearest example is `azure-pipelines-grc-function-app-dev.yml`.

### Plan Stage: Restore Existing State

The pipeline defines:

- `STATE_DIR = statefiles/grc-function-app`
- `TFSTATE_ARTIFACT_NAME = tfstate-grc-function-app`

The `ProbeSeedRun` task uses the Azure DevOps REST API and `System.AccessToken` to inspect previous successful runs of the same pipeline definition and branch.

It looks specifically for a run that contains the expected Terraform-state artifact.

If found, `DownloadPipelineArtifact@2` downloads that artifact into the configured state directory.

The pipeline then copies:

`statefiles/grc-function-app/terraform.tfstate`

into:

`grc-function-app/terraform.tfstate`

Terraform is initialized locally using:

`terraform init -backend=false`

Terraform plan therefore reads the restored local `terraform.tfstate`.

### Plan-to-Apply Handoff

The Plan stage writes the saved Terraform plan as `tfplan`.

It then packages the plan and local state into:

`tfbundle.tgz`

That bundle is published as the current run's Plan artifact.

### Apply Stage

The Apply stage downloads the Plan artifact and extracts the bundle into the Terraform working directory.

Terraform initializes again with the backend disabled and applies the saved plan:

`terraform apply -input=false tfplan`

After Apply, the updated local `terraform.tfstate` is copied back to the component state directory and published as the `tfstate-grc-function-app` Azure DevOps Pipeline Artifact.

That artifact becomes the state seed for a later successful run.

### Storage Location

For this pattern, the persistent state copy is therefore stored in **Azure DevOps Pipeline Artifacts associated with pipeline runs**.

It is not stored in Git and it is not stored in the AILZ AzureRM backend.

During Terraform execution, the active working copy is a local `terraform.tfstate` file on the Azure DevOps agent.

---

# 8. End-to-End Example: GRC AI Search

The GRC AI Search deployment shows how the two repository layers work together without sharing Terraform state.

## Step 1 — AILZ Establishes the Platform Network

`AILZ/main.tf` defines the landing-zone networking through the AI Landing Zone Azure Verified Module.

`AILZ/vwan_hub_peering.tf` connects that VNet to the existing Virtual WAN hub.

The Private Endpoint subnet exists as part of the deployed platform environment.

## Step 2 — The IaC Pipeline References the Existing AILZ Subnet

The workload pipeline is:

`azure-pipelines-grc-ai-search-dev.yml`

The pipeline contains `PE_SUBNET_ID`, which is the existing Azure resource ID for the landing-zone Private Endpoint subnet.

The pipeline does not call AILZ Terraform and does not read AILZ Terraform state.

## Step 3 — The Pipeline Selects the Workload Terraform Stack

The pipeline uses:

`TF_DIR = grc-ai-search`

The Terraform input is declared in:

`grc-ai-search/variables.tf`

as:

`private_endpoint_subnet_id`

## Step 4 — Existing Workload Resources Are Reconciled

Before Terraform plan, `azure-pipelines-grc-ai-search-dev.yml` checks global Search name availability.

If a Search service with the requested name exists in an accessible subscription and is not represented in local Terraform state, the pipeline imports the existing service.

The pipeline can perform similar adoption logic for an existing Search Private Endpoint.

## Step 5 — Private DNS Information Is Discovered

The pipeline reads the existing Private Endpoint DNS configuration where applicable and resolves the relevant Search Private DNS zone resource ID.

It passes that information to Terraform through:

`private_dns_zone_ids`

## Step 6 — `grc-ai-search/main.tf` Manages the Workload

`grc-ai-search/main.tf` creates or manages the GRC Azure AI Search service.

When Private Endpoint deployment is enabled, the same Terraform file creates the workload Private Endpoint using:

`subnet_id = var.private_endpoint_subnet_id`

The DNS zone group uses the `private_dns_zone_ids` supplied by the pipeline.

At this point the responsibility split is explicit:

- **AILZ** owns the underlying network and shared platform foundation.
- **GRC AI Search IaC** owns the workload Search service and workload Private Endpoint.

## Step 7 — Plan Is Handed to Apply

The pipeline writes the Terraform plan to `tfplan`.

It creates the artifact:

`grc-aisearch-tf-artifact`

containing the saved plan and local Terraform state when present.

## Step 8 — Apply Uses the Saved Plan

The Apply stage downloads and extracts the current run's artifact.

Terraform initializes locally with the backend disabled and applies the saved plan.

The final deployment path is therefore:

> **AILZ platform network → existing Private Endpoint subnet resource ID → `azure-pipelines-grc-ai-search-dev.yml` → `grc-ai-search/variables.tf` → `grc-ai-search/main.tf` → workload Search service and Private Endpoint**

---

# 9. Deployment Dependency Model

The architecture establishes a natural deployment dependency order.

## 9.1 Platform Prerequisites

The shared hub/connectivity and central platform services must exist before the landing-zone integration that depends on them.

## 9.2 AILZ

AILZ establishes the AI landing-zone platform, including the networking and shared-resource dependencies required by downstream workloads.

Workloads that require an AILZ subnet, DNS integration, or shared Key Vault should not be deployed before those dependencies are available.

## 9.3 Shared IaC Components

The shared workload-side components can then be deployed, principally:

- `shared-app-insights/`
- `shared-app-service/`

## 9.4 Workload Components

### GRC Function App

The Function App requires the existing App Service Plan.

Its Private Endpoint also requires the existing landing-zone Private Endpoint subnet.

### GRC AI Search

The Search workload requires the AILZ Private Endpoint subnet when private networking is enabled and requires the appropriate Private DNS environment.

### Easement Document Intelligence

The workload consumes the existing shared Key Vault when service-key persistence is enabled.

Its pipeline also carries the AILZ Private Endpoint subnet as a prepared input, although the reviewed Easement Private Endpoint Terraform block is currently disabled/commented.

### Foundation ADF

The reviewed ADF Terraform does not show the same direct dependency on an AILZ resource ID. It depends on its configured data/service endpoints and the target Azure environment.

---

# 10. Architectural Change Boundary

The repository structure provides a practical technical boundary for future changes.

## Changes that belong to the AILZ/platform layer

Examples include:

- VNet architecture changes
- New landing-zone subnets
- Existing subnet resizing or platform networking changes
- Virtual WAN hub connectivity
- Central Private DNS architecture
- Shared landing-zone services
- AI platform capabilities configured by the AILZ module

## Changes that belong to the workload IaC layer

Examples include:

- GRC Function App configuration
- GRC AI Search service configuration
- Workload-specific Private Endpoints
- Shared App Service Plan
- Shared App Insights
- Easement Document Intelligence
- Foundation ADF resources

A workload Private Endpoint illustrates the boundary clearly: **the workload stack owns the Private Endpoint object, while AILZ owns the platform subnet into which that endpoint is placed.**

---

# 11. Key Architectural Conclusions

1. **AILZ is the platform foundation, not merely a networking repository.** It contains the Azure AI and ML Landing Zone module configuration, networking, hub integration, DNS integration, and broader AI/shared-platform definitions.

2. **The IaC repository is the workload deployment layer.** It manages workload-specific and shared application services through individual Terraform stacks and Azure DevOps pipelines.

3. **The repositories are connected by deployed Azure resources, not by shared Terraform state.** Existing subnet IDs, Key Vault IDs, resource names, and runtime discovery form the contract between the layers.

4. **AILZ uses an AzureRM remote backend.** Its state is stored in Azure Storage. The exact backend resource group, storage account, container, and key are not visible in the root Terraform code reviewed and therefore are not asserted in this document.

5. **IaC state handling varies by workload pipeline.** Shared App Service, Shared App Insights, and GRC Function App explicitly persist state across runs using Azure DevOps Pipeline Artifacts. GRC AI Search and Easement carry local state between Plan and Apply but do not show a separate post-Apply state publication in the supplied YAML. Foundation ADF does not show durable cross-run state persistence in the supplied pipeline. The LZ smoke pipeline separately uses AzureRM backend state.

6. **Not every AILZ platform definition is currently consumed by workload IaC.** The strongest confirmed cross-repository integrations in the reviewed code are the landing-zone networking/Private Endpoint subnet, the DNS platform context used by Search, and the shared Key Vault used by Easement.

7. **A service type appearing in both repositories does not mean it is the same Terraform resource.** AILZ AI Search definitions and the workload-specific GRC AI Search stack have separate Terraform ownership unless an explicit reference establishes otherwise.

8. **The reviewed workload stacks generally use existing resource groups.** They deploy workload resources into established platform boundaries rather than creating the full landing-zone resource-group hierarchy.

---

# Appendix A — File Reference Index

## AILZ Repository

- `azure-pipelines.yml`
- `cd_ai_landingzone.yaml`
- `terraform.tf`
- `local.tf`
- `main.tf`
- `variables.tf`
- `vwan_hub_peering.tf`

## IaC Root Pipelines

- `azure-pipelines-shared-app-service-dev.yml`
- `azure-pipelines-shared-app-insights-dev.yml`
- `azure-pipelines-grc-function-app-dev.yml`
- `azure-pipelines-grc-ai-search-dev.yml`
- `azure-pipelines-easement-document-intelligence-dev.yml`
- `azure-pipelines-foundation-ADF-dev.yml`
- `azure-pipelines-lz-terraform-smoke.yml`
- `azure-pipelines-sp-permissions-check.yml`

## IaC Pipeline Templates

- `templates/ensure-az-cli.yml`
- `templates/bootstrap-terraform.yml`

## Shared App Service

- `shared-app-service/main.tf`
- `shared-app-service/variables.tf`
- `shared-app-service/outputs.tf`
- `shared-app-service/versions.tf`
- `shared-app-service/backend.tf`

## Shared App Insights

- `shared-app-insights/main.tf`
- `shared-app-insights/variables.tf`
- `shared-app-insights/outputs.tf`
- `shared-app-insights/versions.tf`
- `shared-app-insights/README.md`

## GRC Function App

- `grc-function-app/main.tf`
- `grc-function-app/variables.tf`
- `grc-function-app/outputs.tf`
- `grc-function-app/providers.tf`
- `grc-function-app/versions.tf`
- `grc-function-app/backend.tf`
- `grc-function-app/README.md`

## GRC AI Search

- `grc-ai-search/main.tf`
- `grc-ai-search/variables.tf`
- `grc-ai-search/outputs.tf`
- `grc-ai-search/backend.tf`
- `grc-ai-search/README.md`

## Easement Document Intelligence

- `easement-document-intelligence/main.tf`
- `easement-document-intelligence/variables.tf`
- `easement-document-intelligence/outputs.tf`
- `easement-document-intelligence/README.md`

## Foundation ADF

- `foundation-adf-pipeline/main.tf`
- `foundation-adf-pipeline/providers.tf`
- `foundation-adf-pipeline/variables.tf`
- `foundation-adf-pipeline/adf_integration_runtime.tf`
- `foundation-adf-pipeline/adf_linked_services.tf`
- `foundation-adf-pipeline/adf_datasets.tf`
- `foundation-adf-pipeline/adf_pipeline.tf`
- `foundation-adf-pipeline/README.md`

## Landing-Zone Smoke Test

- `tests/lz-smoke/main.tf`
- `tests/lz-smoke/variables.tf`
- `tests/lz-smoke/outputs.tf`

---

# Appendix B — Cross-Repository Reference Trace

| Platform Dependency | AILZ Definition / Context | IaC Reference Point | IaC Terraform Consumer |
|---|---|---|---|
| Landing-zone Private Endpoint subnet | `AILZ/main.tf` | `azure-pipelines-grc-function-app-dev.yml` → `PE_SUBNET_ID` | `grc-function-app/variables.tf` → `grc-function-app/main.tf` |
| Landing-zone Private Endpoint subnet | `AILZ/main.tf` | `azure-pipelines-grc-ai-search-dev.yml` → `PE_SUBNET_ID` | `grc-ai-search/variables.tf` → `grc-ai-search/main.tf` |
| Private DNS platform context | AILZ landing-zone DNS configuration | `azure-pipelines-grc-ai-search-dev.yml` runtime DNS discovery | `grc-ai-search/variables.tf` → Private DNS zone group in `grc-ai-search/main.tf` |
| Existing shared Key Vault | Key Vault definition/context in `AILZ/main.tf` | Key Vault resource ID in `azure-pipelines-easement-document-intelligence-dev.yml` | `easement-document-intelligence/variables.tf` → Key Vault secret resources in `easement-document-intelligence/main.tf` |
| Virtual WAN hub integration | `AILZ/vwan_hub_peering.tf` | No direct workload input required | Indirect platform connectivity used by workloads attached to the AILZ VNet |

---

## Final Architectural Statement

> **The AILZ repository in Cloud Services - Azure - AILZ establishes and state-manages the AI landing-zone platform. The IaC repository in ArtificialIntelligence independently deploys and state-manages the workload services. Workload pipelines connect to AILZ by passing or discovering existing Azure resource IDs and names, not by sharing or reading the AILZ Terraform state.**
