FROM ubuntu:18.04

ENV HORIZON_BASEDIR=/opt/horizon \
    LANG=C \
    VERSION="stable/ussuri"

COPY . ${HORIZON_BASEDIR}
WORKDIR ${HORIZON_BASEDIR} 

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
    apt-transport-https ca-certificates curl software-properties-common \
    python3-minimal python3 python3-dev python3-pip python3-venv \ 
    python3-wheel python3-setuptools \ 
    git wget gettext libpcre3-dev libpcre++-dev libyaml-dev 

RUN cd ${HORIZON_BASEDIR} && \
    pip3 install --upgrade --user pip && \
    python3 -m pip install rcssmin --install-option="--without-c-extensions" && \
    python3 -m pip install . && \
    python3 -m pip install python-memcached && \
    python3 -m pip install oslo-log && \
    cp openstack_dashboard/local/local_settings.py.dev openstack_dashboard/local/local_settings.py && \
    git clone https://github.com/openstack/heat-dashboard && \
    pip install -e ./heat-dashboard/ && \
    cp heat-dashboard/heat_dashboard/enabled/* ${HORIZON_BASEDIR}/openstack_dashboard/local/enabled && \
    cp heat-dashboard/heat_dashboard/conf/* ${HORIZON_BASEDIR}/openstack_dashboard/conf/ && \
    cp heat-dashboard/heat_dashboard/local_settings.d/* ${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.d/ && \
    python3 ./manage.py compilemessages && \
    python3 ./manage.py collectstatic --noinput && \
    python3 ./manage.py compress --force && \
    python3 ./manage.py make_web_conf --wsgi && \
    python3 -m compileall $HORIZON_BASEDIR

EXPOSE 8000
ENTRYPOINT ["python3", "/opt/horizon/manage.py","runserver","0.0.0.0:8000"]
