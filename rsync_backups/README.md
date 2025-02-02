# Rsync Backups add-on for Home Assistant

Transfers the Hass.io backups to a remote rsync server.

## Configuration

This section describes each of the add-on configuration options.

Example add-on configuration:

```yaml
server: rsync-server
port: 22
directory: ~/hassio-backups
auto_purge: 0
```

### Option: `server` (required)

Server host or IP, e.g. `localhost`.

### Option: `port` (required)

Server ssh port, e.g. `22`.

### Option: `directory` (required)

Directoryon the server for backups, e.g. `~/hassio-backups`.


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
    - service: 'hassio.backup_full'
      data_template:
        name: "Automated Backup {{ now().strftime('%Y-%m-%d') }}"
        password: !secret hassio_snapshot_password
    # wait for snapshot done, then sync snapshots
    - delay: '00:10:00'
    - service: 'hassio.addon_start'
      data:
        addon: '2caa1d32_rsync_backups' # you can get the addon id from URL when you go to the addon info
```

## New in 1.0.10

Two new options: state notification binary sensor, and access token.
If you fill these two fields, a new binary sensor will be updated by addon when it runs:
when the addon starts it will be on, if the rsync fail it will be set to off.
For example: you can create an automation that check this sensor and notifiy you in case of fail.
