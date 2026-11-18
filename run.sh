#!/bin/sh

ESC=$(printf '\033')
RED="${ESC}[31m"
RESET="${ESC}[0m"

fatal() {
	echo "${RED}FATAL:" "$@" "$RESET" >&2
	exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "usage: $0 [OPTIONS]"
	echo "       $0 [OPTIONS] <python_script>"
	echo "       $0 [OPTIONS] <command> <args> # without args the command is taken as a script"
	echo
	echo "OPTIONS:"
	echo "  -h, --help   Show this message"
	echo "      --build  Force build of the docker image"
	echo
	exit 0
fi

if [ "$1" = "--build" ] || ! docker image inspect mininet >/dev/null 2>&1; then
	docker build -t mininet ./docker -f ./docker/Dockerfile || fatal "failed to build image"
	shift
fi

# the host kernel needs the OVS module (the container uses the host's kernel)
if ! lsmod | grep -q openvswitch; then
	sudo modprobe openvswitch || fatal "failed to enable openvswitch kernel module"
fi

if [ $# -lt 1 ]; then
	# interactive shell
	docker run --rm -it --privileged -v /lib/modules:/lib/modules:ro \
		-v "$PWD":/work mininet
elif [ $# -eq 1 ]; then
	# run a script directly
	docker run --rm -it --privileged -v /lib/modules:/lib/modules:ro \
		-v "$PWD":/work mininet python3 "$1"
else
	docker run --rm -it --privileged -v /lib/modules:/lib/modules:ro \
		-v "$PWD":/work mininet "$@"
fi
