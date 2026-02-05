---
title: Migrate from v14 to v15
---

This guide will help you migrate from `v14` to version `v15` of `wg-easy`.

## Changes

- This is a complete rewrite of the `wg-easy` project, therefore the configuration files and the way you interact with the project have changed.
- If you use armv6 or armv7, you unfortunately won't be able to migrate to `v15`.
- If you are connecting to the Web UI via HTTP, you need to set the `INSECURE` environment variable to `true`.

## Migration

### Backup

Before you start the migration, make sure to back up your existing configuration files.

Go into the Web UI and click the Backup button, this should download a `wg0.json` file.

You will need this file for the migration.

You will also need to back up the old environment variables you set, as they will not be automatically migrated.

### Stop the old instance

Stop the running `wg-easy` process and make sure it does not restart automatically.

### Install the new version

Follow the instructions in the [Getting Started][docs-getting-started] guide to install the new version.

In the setup wizard, select that you already have a configuration file and upload the `wg0.json` file you downloaded in the backup step.

[docs-getting-started]: ../../getting-started.md

### Environment Variables

v15 does not use the same environment variables as v14, most of them have been moved to the Admin Panel in the Web UI.

### Done

You have now successfully migrated to `v15` of `wg-easy`.
