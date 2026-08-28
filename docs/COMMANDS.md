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


## All-In AI Stack

```bash
hermestools
hermestools setup
hermestools status
hermestools doctor

hermestools router install
hermestools router dashboard
hermestools router link
hermestools router models
hermestools router use MODEL_ID
hermestools router status
hermestools router logs 100
hermestools router restart
hermestools router update

hermestools genspark install
hermestools genspark auth
hermestools genspark test
hermestools genspark sync
hermestools genspark search "query"

hermestools skills refresh
```
