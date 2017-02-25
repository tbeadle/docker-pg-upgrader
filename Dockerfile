FROM debian:jessie

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7

RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates python wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& (wget -O - https://bootstrap.pypa.io/get-pip.py | python) \
	&& apt-get purge -y --auto-remove ca-certificates wget

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

RUN bash -c "\
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' 9.4 > /etc/apt/sources.list.d/pgdg.list \
	&& echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' 9.5 > /etc/apt/sources.list.d/pgdg.list \
	&& echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' 9.6 > /etc/apt/sources.list.d/pgdg.list \
	"

RUN apt-get update \
	&& apt-get install -y postgresql-common \
	&& sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
	&& apt-get install -y \
		postgresql-9.4 \
		postgresql-contrib-9.4 \
		postgresql-9.5 \
		postgresql-contrib-9.5 \
		postgresql-9.6 \
		postgresql-contrib-9.6 \
	&& rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/postgresql
ENV PGDATAOLD=/var/lib/postgresql/old \
	PGDATANEW=/var/lib/postgresql/new \
	NEW_VER=9.6 \
	OLD_VER= \
	JOB=5 \
	LINK=1 \
	CHECK= \
	PGUSER=postgres

COPY entrypoint.sh /
WORKDIR /tmp
CMD [ "/entrypoint.sh" ]
