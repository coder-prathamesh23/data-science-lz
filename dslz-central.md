# Data Science Landing Zone and Central Landing Zone Architecture

## 1. Purpose

This section describes the high-level architecture of the **Data Science Landing Zone (DSLZ)** and the **Central Landing Zone**, and explains how the two work together to support the end-to-end MLOps platform across **Development (DEV), Quality Assurance (QA), and Production (PROD)** environments.

The design separates environment-specific MLOps resources from shared central services. Each DSLZ environment provides the infrastructure required to run machine learning workloads independently, while the Central Landing Zone provides shared services that can be accessed by DEV, QA, and PROD.

This separation gives the platform a consistent environment model while keeping shared ML and AI services in a central location.

---

# 2. High-Level Architecture

The overall architecture is divided into two main areas:

- **Data Science Landing Zone (DSLZ)** — environment-specific infrastructure deployed separately for DEV, QA, and PROD.
- **Central Landing Zone** — shared infrastructure used across the DSLZ environments.

At a high level, the relationship is:

**DSLZ DEV / QA / PROD → Central Landing Zone shared services**

Each DSLZ environment remains isolated from the others at the environment level, but can connect to and consume the services hosted centrally.

The same overall DSLZ design is used across DEV, QA, and PROD. The purpose of each environment may differ, but the underlying platform structure remains consistent.

---

# 3. Data Science Landing Zone (DSLZ)

The Data Science Landing Zone provides the environment-specific infrastructure required for machine learning development, validation, deployment, and runtime activities.

A separate DSLZ environment exists for:

- **DEV**
- **QA**
- **PROD**

The DSLZ architecture is defined once and applied consistently across these environments. Each environment has its own instance of the required platform resources and its own environment-specific access, networking, monitoring, and security boundaries.

## 3.1 DSLZ Resources

Each DSLZ environment contains the following major resources and platform capabilities.

### Azure Machine Learning Workspace

The Azure Machine Learning Workspace is the primary machine learning workspace for the environment. It provides the platform used to run machine learning workloads and interact with the services required by the MLOps lifecycle.

### Compute Clusters

Azure Machine Learning compute is available within the DSLZ environment to support workload execution.

DEV is primarily used for model development and training. QA is used for validation and testing, while PROD is used for production workloads and inference.

### Managed DevOps Pool

The Managed DevOps Pool provides the managed build and deployment agent capability required for supported automation and deployment activities associated with the MLOps platform.

### Storage Account

Each DSLZ environment has its own Storage Account for environment-specific machine learning storage requirements, including workspace data and artifacts used within that environment.

### Key Vault

Each DSLZ environment has its own Key Vault capability for securely storing and accessing secrets, keys, and other protected configuration required by that environment.

### Networking

Each DSLZ environment has dedicated networking components that provide controlled connectivity for the environment.

Networking supports private access to platform resources and connectivity to required shared services while maintaining separation between DEV, QA, and PROD.

### Role-Based Access Control (RBAC)

RBAC is applied at the environment level to control which users, service principals, managed identities, and workloads can access each resource.

This keeps permissions scoped to the appropriate environment and allows workloads to access only the resources they require.

### Monitoring and Logging

Monitoring and logging are part of the DSLZ platform design so that infrastructure and machine learning workloads can be observed and operational issues can be investigated.

Monitoring remains environment-specific so that DEV, QA, and PROD activity can be reviewed independently.

---

# 4. DSLZ Environment Model

The three DSLZ environments use the same overall platform structure but serve different stages of the MLOps lifecycle.

## DEV

DEV is the primary environment for model development and training.

Data scientists and engineers use the DEV Azure Machine Learning environment to build, test, and train models before model artifacts are made available through the shared Central Landing Zone services.

## QA

QA is used to validate models and MLOps workflows before they are introduced into Production.

The QA environment consumes the appropriate shared model artifacts and services from the Central Landing Zone and provides an isolated environment for testing and validation.

## PROD

PROD is the production machine learning environment.

It consumes the approved model artifacts and shared services required for production execution and inference while remaining isolated from DEV and QA.

---

# 5. Central Landing Zone

The Central Landing Zone provides the shared services used across the MLOps platform.

Instead of creating separate shared ML and AI services inside DEV, QA, and PROD, these services are maintained centrally and made available to the DSLZ environments through controlled access.

The Central Landing Zone therefore acts as the common shared-service layer between the individual DSLZ environments.

## 5.1 Central Model Registry

The Central Landing Zone contains an **Azure Machine Learning Registry** that is used specifically as the platform's shared **Model Registry**.

Its purpose is to provide a common location for model artifacts and model versions that need to be shared across environments.

The Model Registry supports the lifecycle in which models developed and trained in DEV can be made available centrally and then consumed by QA and PROD as part of the controlled MLOps process.

The Central Registry is not intended to function as an additional DEV, QA, or PROD machine learning workspace. Its role is specifically to provide the shared model registry capability.

## 5.2 Shared Azure AI Foundry

Azure AI Foundry is hosted in the Central Landing Zone as a shared service.

AI Foundry is not deployed separately inside the DEV, QA, or PROD DSLZ environments.

Where AI Foundry capabilities are required by an environment, that environment connects to and uses the centrally hosted Foundry resources through the appropriate networking and access controls.

This keeps the AI Foundry capability centralized rather than duplicating it across each DSLZ environment.

## 5.3 Container Registry

The Central Landing Zone includes the shared Container Registry capability required by the central ML/AI platform.

This provides centralized storage for container images and related artifacts required by the shared services.

## 5.4 Storage Account

Central Storage provides the shared storage capability required by the Central Landing Zone services and shared ML/AI artifacts.

This storage is separate from the environment-specific Storage Accounts used inside DEV, QA, and PROD.

## 5.5 Key Vault

The Central Landing Zone contains the protected secret and key management capability required by centrally hosted services.

Central services use this capability independently of the environment-specific Key Vaults maintained inside each DSLZ environment.

## 5.6 Monitoring and Logging

Central services have monitoring and logging capabilities so that the health and activity of shared platform resources can be monitored separately from the individual DSLZ environments.

This provides visibility into the shared components that may be consumed by multiple environments.

## 5.7 Central RBAC

RBAC controls access from DEV, QA, and PROD to the shared Central Landing Zone resources.

Environment identities are granted access only to the Central services required for their workload.

This provides the authorization boundary between the environment-specific DSLZ resources and the centrally hosted shared services.

---

# 6. Relationship Between DSLZ and Central Landing Zone

The DSLZ and Central Landing Zone are designed as separate but connected parts of the MLOps platform.

The DSLZ provides the resources required to operate an individual machine learning environment, while Central provides services that need to be shared across environments.

The relationship can be summarized as follows:

**DEV / QA / PROD DSLZ environments → controlled network and identity access → Central shared services**

The connection between the two areas relies on two separate controls:

1. **Network connectivity** — the DSLZ environment must have a valid private network path to the required Central service.
2. **Identity and RBAC** — the identity used by the environment must have the appropriate authorization on the Central resource.

Both conditions are required. Network connectivity by itself does not provide access, and RBAC by itself does not provide network reachability.

---

# 7. Shared Model Lifecycle

The architectural model for the platform is:

**DEV → Central Model Registry → QA → PROD**

DEV is where models are primarily developed and trained.

Once a model is ready to move beyond development, the model artifact is made available through the Central Azure Machine Learning Model Registry. The Central Registry provides the shared location from which the appropriate model version can be consumed by downstream environments.

QA then uses the centrally available model artifact for validation and testing.

Following successful validation and the required approval process, PROD consumes the approved model version for production use.

This design avoids making DEV itself the shared source for downstream environments. DEV remains a development environment, while the Central Landing Zone provides the shared location used to make model artifacts available across the MLOps lifecycle.

---

# 8. Environment Isolation and Shared-Service Consumption

DEV, QA, and PROD are maintained as separate environments.

Each environment owns its own:

- Azure Machine Learning Workspace
- Compute capability
- Managed DevOps Pool
- Storage Account
- Key Vault
- Networking
- RBAC
- Monitoring and logging

The Central Landing Zone owns the shared services that are intended to be common across environments, including:

- Central Azure Machine Learning Model Registry
- Shared Azure AI Foundry
- Central Container Registry
- Central Storage Account
- Central Key Vault
- Central monitoring and logging
- Central RBAC

This separation allows each environment to operate independently while still consuming common ML and AI services from a controlled central location.

---

# 9. Networking and Access Model

Connectivity between DSLZ environments and the Central Landing Zone is designed around private and controlled communication.

Each environment has its own networking boundary and accesses Central services through the approved enterprise network path and private connectivity model.

Private Endpoints are used where applicable so that platform services can be reached privately rather than through unrestricted public network access.

The enterprise networking layer provides the broader connectivity required between landing zones, while environment-specific networking controls access within each DSLZ environment.

RBAC is applied separately from the network configuration to control which identities are allowed to interact with Central services.

---

# 10. Architectural Responsibility Boundary

## Data Science Landing Zone

The DSLZ is responsible for providing the environment-specific machine learning platform for DEV, QA, and PROD.

It contains:

- Azure Machine Learning Workspace
- Compute Clusters
- Managed DevOps Pool
- Storage Account
- Key Vault
- Environment networking
- Environment RBAC
- Environment monitoring and logging

## Central Landing Zone

The Central Landing Zone is responsible for shared ML and AI services that should not be duplicated independently across DEV, QA, and PROD.

It contains:

- Azure Machine Learning Model Registry
- Shared Azure AI Foundry
- Container Registry
- Storage Account
- Key Vault
- Central monitoring and logging
- Central RBAC

## Connection Between the Two

The DSLZ environments consume the shared services in Central through controlled networking and RBAC.

The Central Landing Zone therefore provides the common shared-service layer, while DEV, QA, and PROD remain separate execution environments.

---

# 11. Architecture Summary

The Data Science Landing Zone and Central Landing Zone together form the platform foundation for the MLOps lifecycle.

The **DSLZ** provides three isolated environments—DEV, QA, and PROD—with a consistent set of machine learning infrastructure, networking, security, and operational services.

The **Central Landing Zone** provides the shared model and AI services used across those environments, with the Azure Machine Learning Registry acting as the shared Model Registry and Azure AI Foundry operating as a centrally hosted AI service.

The overall architecture can therefore be summarized as:

**DSLZ DEV**  
Model Development and Training

**↓**

**Central Landing Zone**  
Shared Model Registry and Shared AI Services

**↓**

**DSLZ QA**  
Validation and Testing

**↓**

**DSLZ PROD**  
Production Execution and Inference

The key design principle is that DEV, QA, and PROD remain independent environments, while resources that need to be shared across the MLOps lifecycle are maintained centrally and accessed through controlled private networking and role-based access.
