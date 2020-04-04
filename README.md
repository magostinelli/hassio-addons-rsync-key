# Rsync Backups add-on for Home Assistant

Transfers the Hass.io backups to a remote rsync server.

## Instalation

Download and place files in `rsync_backups` directory in  `addons` of Home Assistant.
Files from this repository should be in the `[homeassistant]/addons/rsync_backups`.

## Configuration

This section describes each of the add-on configuration options.

Example add-on configuration:

```
"server": "rsync-server",
"port": 22,
"directory": "~/hassio-backups",
"username": "user",
"password": "password",
"auto_purge": 0
```

### Option: `server` (required)

Server host or IP, e.g. `localhost`.

### Option: `port` (required)

Server ssh port, e.g. `22`.

### Option: `directory` (required)

Directoryon the server for backups, e.g. `~/hassio-backups`.

### Option: `user` (required)

Server ssh user, e.g. `root`.

### Option: `password` (required)

Server ssh password, e.g. `password`.

### Option: `auto_purge` (required)

The number of recent backups keep in Home Assistant, e.g. "5". Set to "0" to disable automatic deletion of backups.

## How to use

Run addon in the automation, example automation below:

```yaml
- alias: 'hassio_daily_backup'
  trigger:
    platform: 'time'
    at: '3:00:00'
  action:
    - service: 'hassio.snapshot_full'
      data_template:
        name: "Automated Backup {{ now().strftime('%Y-%m-%d') }}"
        password: !secret hassio_snapshot_password
    # wait for snapshot done, then sync snapshots
    - delay: '00:10:00'
    - service: 'hassio.addon_start'
      data:
        addon: 'local_rsync_backups'
```
