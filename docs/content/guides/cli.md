---
title: CLI
---

If you want to use the CLI, run:

```shell
wg-easy-cli
```

### Reset Password

If you want to reset the password for the admin user, you can run the following command:

#### By Prompt

```shell
sudo wg-easy-cli db:admin:reset
```

You are asked to provide the new password.

#### By Argument

```shell
sudo wg-easy-cli db:admin:reset --password <new_password>
```

This will reset the password for the admin user to the new password you provided. If you include special characters in the password, make sure to escape them properly.
