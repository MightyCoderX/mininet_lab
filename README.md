# Mininet LAB

A container-based lab for quickly testing Mininet scripts. Scripts run inside
a Docker container, so nothing Mininet-related is installed on your host. A
local virtualenv also provides the `mininet` Python package, so any
LSP-enabled editor can lint and autocomplete against the real Mininet API.

## Requirements

- Linux host (the container needs a Linux kernel module)
- [Docker](https://docs.docker.com/engine/install/)
- `sudo` privileges, used to load the `openvswitch` kernel module
- Optional, for editor support: Python 3 with venv module and
  [direnv](https://direnv.net/)

## Usage

Start an interactive shell inside the container (your current directory is
mounted at `/work` in the container):

```sh
./run.sh
```

Run a script directly:

```sh
./run.sh example.py
```

Run a command in the container:

```sh
./run.sh mn --topo single,3 --test pingall
```

The image is built automatically on first run. Docker's layer cache makes
later builds nearly instant unless you edit the Dockerfile.

Inside the shell you can also use the Mininet CLI directly:

```sh
mn --topo single,3 --test pingall
```

If you want to add some packages or modify the Dockerfile in anyway you
can force a rebuild by passing the `--build` flag **AS THE FIRST ARGUMENT**
of the `./run.sh` script.

Run `./run.sh --help` for the command's syntax.

## Editor support (optional)

The container has its own Python, so the host venv exists only so your
editor's language server can resolve `import mininet`.

With direnv, it is created and activated automatically:

```sh
direnv allow
```

Without direnv:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Layout

```
.
├── docker
│   ├── Dockerfile       # Ubuntu + Mininet + Open vSwitch + network utilities
│   └── entrypoint.sh    # starts OVS, then runs your command
├── example.py           # sample topology
├── requirements.txt     # Python deps for the host venv (editor tooling)
├── run.sh               # build + launch the container
└── .envrc               # direnv: create/activate the venv
```

## Notes

- **`--privileged` is required.** Mininet creates network namespaces and
  virtual interfaces, which needs real kernel capabilities. Only run scripts
  you trust.
- Only edit files from outside the container, the container is only meant to run
  the scripts, otherwise you will run into permission problems since the
  container runs as root
- **`*** Error setting resource limits` is harmless.** Mininet tries to raise
  some limits and sysctls; it works fine without them for normal topologies.
- **Stale state after a crash:** run `mn -c` inside the container.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `modprobe: FATAL: Module openvswitch not found` | Install your distro's kernel modules package, or use `--switch lxbr` / `OVSBridge` to avoid OVS (as is demonstrated in the example) |
| Script can't find a controller | The image ships `ovs-testcontroller`; for POX/Ryu, add it to the Dockerfile |
| `xterm` windows don't open | Pass `-e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix` and run `xhost +local:` on the host |
