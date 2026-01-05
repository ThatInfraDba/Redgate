# SQL Clone Azure DevOps Automation

This repository contains resources for automating Redgate SQL Clone operations.
All scripts are to be used at your own discretion.

## Overview

SQL Clone enables rapid provisioning of full SQL Server databases using lightweight clones. This repository provides ready-to-use Azure DevOps pipelines for creating images and clones, streamlining database provisioning workflows.

## Repository Structure

### `/Pipeline/`
Contains Azure DevOps YAML pipeline definitions and the SQL Clone PowerShell module.

**Key Contents**:
- **create-sqlclone-image.yml**: Pipeline for creating SQL Clone images from backups or live databases
- **create-sqlclone-clones.yml**: Pipeline for creating multiple clones from an existing image
- **create-image-and-clones.yml**: Combined pipeline that creates an image and clones in one workflow
- **RedGate.SqlClone.PowerShell/**: PowerShell module for SQL Clone automation (auto-installed by pipelines)
- **README.md**: Detailed documentation for pipelines and usage

See [Pipeline/README.md](Pipeline/README.md) for complete pipeline documentation.

## License

The scripts in this repository are free for use and modification.
The Redgate SQL Clone PowerShell module and its dependencies have their own licenses.

## Contributing

This repository is designed for internal use. Contact your DevOps team for pipeline modifications or enhancements.
