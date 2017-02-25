#!/bin/bash

set -eo pipefail

for var in PGDATAOLD PGDATANEW NEW_VER OLD_VER PGUSER; do
	if [[ -z ${!var} ]]; then
		echo "${var} is empty!"
		exit 1
	fi
done

PGBINNEW=/usr/lib/postgresql/${NEW_VER}/bin
PGBINOLD=/usr/lib/postgresql/${OLD_VER}/bin
if [[ ! -d ${PGBINNEW} ]]; then
	echo "Invalid NEW_VER: ${NEW_VER}"
	exit 1
fi
if [[ ! -d ${PGBINOLD} ]]; then
	echo "Invalid OLD_VER: ${OLD_VER}"
	exit 1
fi
if [[ ! -d ${PGDATAOLD} ]]; then
	echo "Old data directory ${PGDATAOLD} does not exist!"
	exit 1
fi
if [[ ! -d ${PGDATANEW} ]]; then
	echo "New data directory ${PGDATANEW} does not exist!"
	exit 1
fi
ARGS="\
	--old-bindir=${PGBINOLD} \
	--new-bindir=${PGBINNEW} \
	--old-datadir=${PGDATAOLD} \
	--new-datadir=${PGDATANEW} \
	--username=${PGUSER} \
	"
if [[ -n ${CHECK} ]]; then
	ARGS+=" --check"
fi
if [[ -n ${JOBS} ]]; then
	ARGS+=" --jobs ${JOBS}"
fi
if [[ -n ${LINK} ]]; then
	ARGS+=" --link"
fi
CMD="gosu postgres ${PGBINNEW}/pg_upgrade ${ARGS}"
echo "Running ${CMD}"
exec ${CMD}
