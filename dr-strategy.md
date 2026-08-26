# MLOps Platform Disaster Recovery Strategy

## Azure DevOps and Microsoft Entra ID

**Azure DevOps**

Azure DevOps is a Microsoft-managed SaaS service, so the regional availability and service-level disaster recovery are handled by Microsoft. Azure DevOps customer data, including repositories, work items, test results, and other organization data, is geo-replicated to a second Azure region within the selected Azure DevOps geography. There is no separate customer-managed Azure DevOps regional failover required for this platform.  

For the MLOps platform, Azure DevOps remains the source of truth for the Terraform code, deployment pipelines, model/pipeline code, and other configuration kept in source control. The DR process should continue to use the existing Azure DevOps repositories and pipelines to rebuild customer-managed Azure resources in the recovery region. Pipeline configuration that is maintained outside Git, such as service connections or environment-specific configuration, should be included in the recovery validation so that deployments can still be run during a DR event. Microsoft is responsible for recovering the Azure DevOps service itself.  

**Microsoft Entra ID**

Microsoft Entra ID is also a Microsoft-managed cloud identity service, so the MLOps team does not deploy a second Entra tenant for regional DR. Microsoft provides service-level resiliency for authentication, while tenant-level recoverability is handled through Microsoft Entra recovery capabilities and administrative recovery procedures. Microsoft now provides Microsoft Entra Backup and Recovery for supported directory objects and configuration, and Microsoft recommends having defined tenant recovery procedures for accidental or malicious configuration changes.  

For the MLOps platform, the main DR responsibility is to make sure that service principals, managed identities, RBAC assignments, and other access required by the platform can be restored when resources are recreated. Where system-assigned managed identities are used, a recreated Azure resource can receive a new principal ID, so the required role assignments must be reapplied through Terraform rather than relying on the old identity. Emergency administrative access to Entra should also remain available through the organization's existing break-glass process. Microsoft recommends maintaining at least two emergency access accounts that do not depend on the normal administrative authentication path. citeturn5search22

## Azure Virtual Network and Azure Virtual Network Gateways

**Azure Virtual Network**

Azure Virtual Network is a regional service. It is resilient across availability zones within a supported region, but a VNet in one region does not automatically move to another region if the complete region is unavailable. Microsoft recommends creating equivalent VNets in multiple regions when regional resiliency is required.  

For this platform, the VNet, subnets, routing configuration, peering, and other network configuration should remain defined in Terraform. During DR, the same infrastructure code should be used to deploy the required network configuration into the approved recovery region. Address ranges must be planned so that the recovery VNet does not introduce routing conflicts with existing enterprise or on-premises networks. There is no data backup requirement for the VNet itself; recovery is based on recreating the configuration from Infrastructure-as-Code.  

The same approach applies to the networking needed by the central platform and the Dev, QA, and Prod environments. Whether a recovery VNet is kept available ahead of time or created when DR is declared should be based on the recovery time required for that environment.

**Azure Virtual Network Gateways**

Virtual Network Gateways should use zone-redundant gateway SKUs where supported, particularly for Production. Microsoft recommends zone redundancy for production workloads because supported VPN and ExpressRoute gateways can distribute gateway instances across availability zones and automatically continue operating during a zone failure.  

A region-wide outage is different. The gateway in the affected region cannot provide connectivity for workloads that have moved to another region. The DR network therefore needs an equivalent gateway in the recovery region, together with the required VPN or ExpressRoute connections and routing. Microsoft specifically calls out deploying a new VPN Gateway and reconnecting it to the on-premises network when a workload is recovered to another region.  

For the MLOps platform, the gateway and related Azure-side configuration should be maintained in Terraform. The final decision on whether the recovery gateway is permanently available or deployed during DR should follow the required RTO, because the network path must be available before private MLOps services can be used from the recovery environment.

## Azure Key Vault and Azure Private Endpoints

**Azure Key Vault**

Key Vault needs a specific DR approach for this platform because the current MLOps resources are hosted in **West US 3**. Azure Key Vault normally provides Microsoft-managed replication and failover in many paired regions, but Microsoft explicitly lists West US 3 as a region where Microsoft-managed cross-region replication and failover are not supported. We therefore should not document the current Key Vault as automatically failing over to another Azure region.  

The DR strategy should be to maintain a separate Key Vault in the selected recovery region. Microsoft recommends this custom multi-region approach for West US 3: create separate vaults in different regions, use an appropriate process to make the required keys, secrets, and certificates available in the recovery vault, and switch the workload to the recovery vault during DR. Key Vault backup and restore can be used for individual keys, secrets, and certificates, but those backups are point-in-time, do not automatically stay synchronized, and can only be restored within the same Azure subscription and Azure geography. citeturn7view0

The Key Vault resource configuration itself should continue to be recreated through Terraform, including RBAC, networking, diagnostic settings, and private endpoint configuration. Soft delete and purge protection should remain enabled to protect against accidental or malicious deletion. Microsoft strongly recommends both protections for production Key Vaults.  

**Azure Private Endpoints**

Private Endpoints are part of the regional network design and should not be treated as something that automatically moves with the target Azure service. For the MLOps platform, the recovery environment needs private endpoints for the services that are accessed privately, including Storage, Key Vault, Container Registry, Azure Machine Learning, Foundry, and any other private PaaS dependency used by the environment. Microsoft specifically recommends creating VNets and private endpoints in both regions for Azure Machine Learning and Foundry multi-region designs.  

The private endpoints should be recreated through Terraform against the DR-region resources. Private DNS also has to be part of this recovery path. Creating a private endpoint without the correct DNS record or DNS forwarding configuration can leave the service unreachable even though the private endpoint itself is deployed. Microsoft Foundry's DR guidance specifically calls for validating both private endpoints and DNS resolution in the secondary environment.  

For DR validation, connectivity should therefore be tested from the actual MLOps workload or compute environment to the private endpoint. The validation should confirm DNS resolution, network reachability, and authorization to the target service rather than only checking that the Azure private endpoint resource exists.

## Azure Machine Learning and Microsoft Foundry

**Azure Machine Learning**

Azure Machine Learning does not provide automatic regional failover, and Microsoft does not provide backup and restore for workspace metadata such as run history. The DR design therefore needs a separate Azure Machine Learning workspace in the selected recovery region, or the ability to deploy one through Terraform when DR is declared. Microsoft supports hot/hot, hot/warm, and hot/cold approaches; the appropriate level should be selected based on the agreed recovery target rather than assumed in the infrastructure design. 

For this MLOps platform, the existing Terraform modules should remain the recovery mechanism for the central and environment-specific infrastructure. The Dev, QA, and Prod AML environments can be recreated from the same code with recovery-region configuration. Production can have a pre-provisioned secondary environment if its RTO requires it, while the recovery approach for Dev and QA should follow the recovery target defined for those environments.

AML compute is also regional. The recovery workspace needs its own compute resources, and the target region must have enough quota for the VM families required by the workloads. RBAC also needs to be reapplied to the identities created in the recovery environment. Microsoft explicitly includes the workspace, compute, role assignments, VNets, private endpoints, VPN/DNS configuration, and associated resources in the AML multi-region recovery design.  

The **central model registry** should be treated separately from an individual AML workspace. Azure Machine Learning registries support multi-region replication and are specifically designed to make centrally managed assets available to workspaces in different Azure regions. When a registry is configured with multiple regions, Azure provisions storage in the supported regions and uses a geo-replicated Container Registry for the assets. The DR strategy for the central model registry should therefore include the selected recovery region in the registry's replication configuration so that registered models, components, and environments required for redeployment remain available if the primary region is unavailable.  

There is also an important storage limitation. Microsoft states that Azure Machine Learning does **not** support failing over the workspace's default Storage Account by using GRS, GZRS, RA-GRS, or RA-GZRS. Each regional AML workspace should have its own default Storage Account. Data that needs to be available to both regions should be kept separately and given its own replication/recovery design.  

**Microsoft Foundry Service**

Microsoft Foundry also does not provide automatic regional failover or DR for the Foundry project itself. Microsoft's current guidance is to create Foundry resources and projects in multiple Azure regions when regional recovery is required and then switch the application or workload to the secondary project when the primary region is unavailable.  

For the central Foundry setup in this MLOps platform, the Foundry resource/project configuration should remain reproducible through Infrastructure-as-Code. The recovery environment should have the required project, model deployments, connections, identities, RBAC, networking, and private endpoints. Model deployments that are required during DR need to exist in the recovery region and sufficient model quota must be available there; running jobs do not automatically move from the failed project to the recovery project and have to be resubmitted.  

Foundry project artifacts and metadata should not be treated as automatically synchronized between two projects. Microsoft states that Foundry does not automatically synchronize or recover project artifacts and metadata between primary and secondary projects. The recovery approach should therefore keep deployable configuration, model definitions, and pipeline/application code in the central source repository and use the central model registry and other protected dependencies as the source for rebuilding the workload.  

The same Terraform and deployment pipeline should be able to build the recovery Foundry configuration without requiring manual recreation of RBAC or network settings. Microsoft specifically recommends IaC, deploying through CI/CD, creating role assignments in both regions, and creating the VNet/private endpoint/DNS configuration required by each region.  

## Microsoft Fabric

Microsoft Fabric is primarily a Microsoft-managed service, but OneLake regional data protection has to be enabled at the Fabric capacity level. Fabric provides a disaster recovery setting that enables cross-region replication for OneLake data where the required Azure/Fabric regional pairing is supported. The setting covers OneLake data such as Lakehouse and Warehouse data; it does not automatically protect data that is stored outside OneLake.  

The DR strategy should therefore require the Fabric platform owner to enable the DR setting on the Production Fabric capacity where regional recovery is required and to verify that the **OneLake Geo-replication** status is healthy for the workspaces used by MLOps. The replication is managed by Microsoft after the setting is enabled, while MLOps remains responsible for making sure the AML/Foundry recovery environment still has the required identity permissions, OneLake paths, and network access after failover.  

During a major regional incident, Microsoft initiates the Fabric regional failover. However, Fabric DR should not be documented as a complete automatic restoration of every Fabric item. Microsoft notes that some capabilities become read-only or unavailable after regional failover. For example, OneLake data can remain accessible while some Lakehouse, notebook, pipeline, model, experiment, and other item experiences have recovery limitations. Critical code or deployment logic should therefore not exist only inside a Fabric item when that code is also required to rebuild the MLOps platform.  

Data maintained outside OneLake needs a separate backup or replication process owned by the team responsible for that data. For the MLOps DR plan, Fabric should be documented as a platform dependency with Microsoft/Fabric administrators responsible for Fabric service recovery and OneLake BCDR, while MLOps is responsible for reconnecting the recovered AML/Foundry workloads to that data.

## Azure Container Registry and Azure Storage Account

**Azure Container Registry**

Azure Container Registry should use geo-replication when container images need to remain available during a regional outage. Microsoft recommends the Premium tier for production multi-region deployments because native ACR geo-replication is a Premium capability. A geo-replicated registry synchronizes images and artifacts to the configured regional replicas.  

For this MLOps platform, the registry used for training, inference, and other MLOps images should have a replica in the selected DR region if regional continuity is required. ACR monitors the health of its replicas and can route data-plane traffic away from an unavailable regional replica. This allows the same logical registry to continue providing container images to the recovery AML or Foundry environment.  

The ACR resource, RBAC, private networking, diagnostic settings, and regional replication configuration should remain under Terraform. After DR failover, validation should include pulling a known image from the recovery environment rather than only checking the ACR resource status.

**Azure Storage Account**

Storage DR needs to distinguish between general MLOps data and the default storage that belongs to an AML or Foundry workspace. For normal Blob/File data that must survive a regional outage, Azure provides GRS and GZRS options that asynchronously replicate data into a secondary geographic region. ZRS provides protection across availability zones in the primary region but does not, by itself, provide protection against loss of the entire region.  

Where a Storage Account contains business data, training data, model-related files, or other content that needs regional recovery, the redundancy level should be selected based on the required RPO/RTO and service compatibility. Geo-redundant storage can then support customer-managed regional failover when required. Because geo-replication is asynchronous, some recent writes can be lost if they have not reached the secondary region at the time of the outage.  

Storage redundancy does not replace protection against accidental deletion. For critical Blob data, the storage configuration should also use the applicable data-protection features, such as container soft delete, Blob soft delete, and versioning. Microsoft recommends combining these controls where protection from deletion or overwrite is required.  

For **AML default workspace storage**, the strategy is different. Microsoft explicitly states that AML does not support default Storage Account failover through GRS/GZRS/RA-GRS/RA-GZRS. Each AML workspace in the recovery region should have its own default Storage Account. The same restriction is documented for Foundry projects. Therefore, Terraform should create the appropriate default storage alongside each recovery workspace/project rather than attempting to fail over the existing default account underneath an existing AML or Foundry resource.  

The recent Production Storage Account recovery also demonstrates why the data-plane objects need to be considered in the runbook. Recreating a Storage Account resource does not by itself restore deleted containers, files, or the contents previously held in them. The DR process should therefore distinguish between **recreating the Azure resource through Terraform** and **recovering the data stored inside it**.

## Azure Monitor and Azure Log Analytics Service

**Azure Monitor**

Azure Monitor is a Microsoft-managed platform service, so the underlying Azure Monitor service recovery is handled by Microsoft. From the MLOps side, the DR requirement is to make sure that the monitoring configuration used by the platform can still operate after the workload has moved to the recovery environment.

The diagnostic settings, scheduled-query alerts, metric alerts, and other MLOps monitoring configuration should continue to be maintained through Terraform so that they can be applied to the DR resources. Service Health and Resource Health alerts should also remain part of the operational monitoring because they provide notification of Azure service and resource incidents that may trigger the DR process.  

Azure Monitor Action Groups can be configured as global resources. Microsoft states that global Action Groups are persisted in at least two regions and that requests can be processed in another region if part of the Action Group service is unavailable. This makes the existing notification path suitable for receiving DR and service-health notifications, subject to the availability of the configured destination such as email or the organization's incident-management system.  

**Azure Log Analytics Service**

Log Analytics workspaces are regional, so regional continuity of MLOps logs needs to be handled separately. Azure Monitor now supports cross-region **workspace replication**, which creates a secondary copy of the workspace and sends newly ingested logs to both the primary and secondary regions. During a regional issue, the workspace can be switched over so that log ingestion and queries use the secondary region.  

This capability is available for a Log Analytics workspace hosted in **West US 3**. Microsoft currently allows West US 3 workspaces to replicate to supported secondary regions in the North America region group, subject to the supported-region list and the selected DR region. The secondary region should therefore be aligned with the MLOps DR region where possible.  

Workspace replication only protects logs ingested after replication has been enabled; historical logs that existed before the feature was enabled are not copied to the secondary workspace. Also, Log Analytics workspace replication does **not** automatically replicate the associated log-search alert rules. The MLOps alert rules therefore need to remain in Terraform and be deployable in the recovery configuration.  

For the MLOps platform, the DR strategy should be to enable Log Analytics workspace replication where monitoring continuity is required, keep diagnostic and alert configuration in IaC, and test the monitoring path during a DR exercise. After recovery, the validation should confirm that AML, Storage, Key Vault, ACR, Foundry, and other required services are sending logs to the active workspace and that the expected MLOps alerts still trigger successfully.
