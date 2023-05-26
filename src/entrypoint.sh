#!/bin/sh
trap exit SIGTERM

if [ "$$" = 1 ]; then
	while :; do
		sleep infinity
	done
fi

if [ -z "${1+y}" ]; then
	exec "$@"
fi

exec sh -l
