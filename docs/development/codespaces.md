# GitHub Codespaces for plugin development

This repository includes a small development container for people who want to
develop and test a NetBox plugin without installing PostgreSQL, Redis, or the
Python dependencies on their own computer. It is intended for development
only; it does not describe a production deployment.

## Open the NetBox checkout

1. Open the NetBox repository on GitHub and select **Code > Codespaces >
   Create codespace on main** (or on your development branch).
2. Wait for the container to finish creating. The first start installs the
   dependencies, creates `netbox/netbox/configuration.py` if it does not
   already exist, and applies database migrations.
3. Select the **NetBox: start development server** task from
   **Terminal > Run Task**. Open the forwarded port 8000 when prompted.

The generated configuration is ignored by git. Startup never replaces an
existing configuration file, so local settings and secrets are preserved.
PostgreSQL and Redis are provided by the `postgres` and `redis` Compose
services. Their development-only credentials are `netbox`/`netbox`.

## Keep the plugin separate from NetBox

The Codespace checkout is the NetBox source tree. Your plugin should remain a
separate project, for example:

```text
/workspaces/
  netbox/                 # this checkout
  my-netbox-plugin/       # the separate plugin checkout
```

Clone the plugin repository into `/workspaces/` (or use a second local
checkout), then install it into the Codespace's Python environment:

```bash
cd /workspaces/my-netbox-plugin
python -m pip install -e .
```

The editable install means changes in the plugin source are immediately
available to NetBox. Add the plugin's Python package name to `PLUGINS` in
`netbox/netbox/configuration.py`, for example:

```python
PLUGINS = [
    'my_plugin',
]
```

If you add or change plugin models, run the plugin's migrations with the
**NetBox: apply migrations** task.

## Run NetBox and tests

The tasks use `netbox/` as their working directory because that is where
`manage.py` lives:

| Task | Use |
| --- | --- |
| **NetBox: start development server** | Start the server on port 8000 |
| **NetBox: apply migrations** | Apply NetBox and installed plugin migrations |
| **NetBox: run plugin tests** | Run a focused plugin test label using your development configuration |
| **NetBox: run core tests** | Run NetBox tests using the packaged test configuration |

Both test tasks ask for a Django test label, such as
`my_plugin.tests.test_models.MyModelTest` or `dcim.tests.test_api`. The core
task sets `NETBOX_CONFIGURATION=netbox.configuration_testing`, as recommended
for NetBox tests, and points that configuration at the Compose services.
The plugin task uses your development configuration so the plugin listed in
`PLUGINS` is enabled.

The equivalent commands are:

```bash
cd /workspaces/netbox/netbox
NETBOX_CONFIGURATION=netbox.configuration python manage.py test my_plugin.tests
NETBOX_CONFIGURATION=netbox.configuration_testing \
  NETBOX_DB_HOST=postgres NETBOX_REDIS_HOST=redis \
  python manage.py test dcim.tests.test_api
```

Use `--keepdb` for repeated test runs when the schema has not changed. The
full suite is available with `python manage.py test`, but focused tests are
usually faster while developing a plugin.
