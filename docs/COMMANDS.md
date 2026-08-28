# ⌨️ HermesLaunch Commands

## VPS Mode

VPS commands control the systemd Hermes Gateway installed by `install-vps.sh`.

```bash
hermeslaunch status
hermeslaunch logs
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch doctor
hermeslaunch model
hermeslaunch backup
hermeslaunch restore
```

## Termux Mobile Mode

Termux commands control a local `tmux` session running `hermes gateway run`.

```bash
hermeslaunch status
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch logs
hermeslaunch doctor
hermeslaunch model
hermeslaunch gateway-setup
hermeslaunch backup
hermeslaunch restore
hermeslaunch update
hermeslaunch version
```

The command names may look similar, but the supervisors are intentionally different:

```text
VPS    = systemd
Termux = tmux
```


## Provider Manager

Available on both VPS and Termux:

```bash
hermeslaunch provider
hermeslaunch provider list
hermeslaunch provider add
hermeslaunch provider switch
hermeslaunch provider test [slug]
hermeslaunch provider remove [slug]
```

Removal is confirmation-gated and creates a config backup first.
