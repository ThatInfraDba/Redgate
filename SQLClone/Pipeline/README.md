# SQL Clone Azure DevOps Pipelines

This directory contains Azure DevOps YAML pipelines for automating Redgate SQL Clone operations.

## Pipelines

### 1. create-sqlclone-image.yml
Creates a SQL Clone image from either a database backup or a live database.

**Use this when**: You need to create a new image for cloning.

**Parameters**:
- **SQL Clone Server URL**: URL of your SQL Clone server (default: `http://sql22-demo:14145`)
- **Image Name**: Name for the new image (required)
- **Source Type**: Choose between `DatabaseBackup` or `LiveDatabase`
- **Backup File Path**: Required when using DatabaseBackup source type
- **Source SQL Server Instance**: Required when using LiveDatabase source type
- **Source Database Name**: Required when using LiveDatabase source type
- **Image Location**: Network share path where the image will be stored (required)

**Features**:
- Automatic PowerShell module installation from repository
- Support for both backup files and live database sources
- Credential support via variable group or current user
- Parameter validation before execution
- Image verification after creation

---

### 2. create-sqlclone-clones.yml
Creates multiple clones (1-10) from an existing SQL Clone image.

**Use this when**: You have an existing image and want to create one or more clones from it.

**Parameters**:
- **SQL Clone Server URL**: URL of your SQL Clone server (default: `http://sql22-demo:14145`)
- **Image Name**: Name of the existing image to clone from (required)
- **Number of Clones to Create**: Select 1-10 clones
- **Clone Name Prefix**: Prefix for clone names (required) - clones will be named `prefix-1`, `prefix-2`, etc.
- **Target SQL Server Instance**: SQL Server where clones will be created (required)
- **Delete Existing Clones with Same Names**: Option to delete existing clones before creating new ones

**Features**:
- Creates multiple clones in parallel
- Automatic naming with numeric suffixes
- Optional deletion of existing clones
- Summary report of successful/failed clone operations
- List of all clones on target server after creation

---

### 3. create-image-and-clones.yml
Combined pipeline that creates an image AND then creates clones from that image in a single workflow.

**Use this when**: You want to create a fresh image and immediately create clones from it in one operation.

**Parameters**: Combines all parameters from both image and clone pipelines (prefixed with `[IMAGE]` and `[CLONES]` for clarity).

**Features**:
- Two-step process: Image creation → Clone creation
- Maintains separate connections for each step
- All features from both individual pipelines
- Streamlined workflow for complete setup

---

## Prerequisites

### SQL Clone Server
- SQL Clone Server must be running and accessible at the specified URL
- SQL Server instances must be registered with SQL Clone
- Image locations must be registered with SQL Clone

### Azure DevOps Setup

#### Self-Hosted Agent
All pipelines are currently configured to use a self hosted runner called "azureAgent", adjust accordingly with your environment.

#### Variable Group
Create a variable group named **SQLCloneCredentials** with the following secret variables:
- `SQLCloneUsername`: Username for SQL Clone authentication
- `SQLClonePassword`: Password for SQL Clone authentication (mark as secret)

If credentials are not provided, pipelines will fall back to using the agent's current user credentials.

#### Repository
The PowerShell module **RedGate.SqlClone.PowerShell** is included in the repository and will be automatically installed on the agent if not already present, ensure to update this PowerShell module in accordance with your current version.

---

## PowerShell Module

### RedGate.SqlClone.PowerShell/
This directory contains the Redgate SQL Clone PowerShell module (version 5.6.10.7984; please update accordingly) required for all pipeline operations.

**Contents**:
- PowerShell module DLL and manifest
- Help documentation (XML)
- OSS licenses for all dependencies (Backend, Frontend, PowerShell)

**Installation**: The pipelines automatically check if the module is installed on the agent. If not found, it will be installed from this repository location.

---

## Usage Examples

### Creating an Image from a Live Database
1. Run `create-sqlclone-image.yml`
2. Set Source Type to `LiveDatabase`
3. Provide SQL Server Instance and Database Name
4. Specify Image Location and Name

### Creating 5 Clones from an Existing Image
1. Run `create-sqlclone-clones.yml`
2. Enter the existing Image Name
3. Set Number of Clones to `5`
4. Provide Clone Name Prefix (e.g., `Dev` will create `Dev-1`, `Dev-2`, ... `Dev-5`)
5. Specify Target SQL Server Instance

### Complete Workflow (Image + Clones)
1. Run `create-image-and-clones.yml`
2. Configure image creation parameters in the `[IMAGE]` section
3. Configure clone creation parameters in the `[CLONES]` section
4. Pipeline will create the image first, then create clones from it

---

## Troubleshooting

### Connection Issues
- Verify SQL Clone Server is running and accessible
- Check that credentials in the SQLCloneCredentials variable group are correct
- Ensure the agent has network access to the SQL Clone server

### Module Not Found
- The module should install automatically from the repository
- If issues persist, check that the Pipeline/RedGate.SqlClone.PowerShell directory exists and contains the module files

### SQL Server Not Registered
- SQL Server instances must be registered with SQL Clone before use
- Use the SQL Clone UI or PowerShell to register servers

### Image Location Not Found
- Image locations (network shares) must be registered with SQL Clone
- Verify the path is accessible from the agent machine

---

## Documentation

- **SQL Clone Documentation**: https://documentation.red-gate.com/clone/
- **SQL Clone Automation**: https://documentation.red-gate.com/clone/automation
- **PowerShell Module Reference**: See `RedGate.SqlClone.PowerShell.dll-Help.xml` for cmdlet documentation

---

## Support

For issues or questions:
1. Check the pipeline logs for detailed error messages
2. Verify prerequisites are met (agent, credentials, SQL Clone server)
3. Review the SQL Clone documentation for specific cmdlet usage
