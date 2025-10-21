# Docker deployment

Provided are two scripts that can be run on a Linux machine that already has docker installed.

The [`start_qotd.sh`](./deploy/docker/start_qotd.sh) script starts the application containers and the anomaly generator.  It requires 
hostname or IP address for the containers to bind to.

The [`start_load.sh`](./deploy/docker/start_load.sh) script starts the load generator (which can run on a different host).  It requires the hostname or IP address of the QotD web component.

