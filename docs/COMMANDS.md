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



## Multi-Agent Stack

```bash
agentstack
agentstack setup
agentstack status
agentstack doctor
agentstack skills

agentstack opencode install
agentstack opencode update
agentstack opencode status
agentstack opencode run "prompt"

agentstack openclaw install
agentstack openclaw onboard
agentstack openclaw status
agentstack openclaw doctor
agentstack openclaw start
agentstack openclaw restart
agentstack openclaw stop
agentstack openclaw update
```
