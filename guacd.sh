#!/bin/bash
# docker run --rm --name guacd  -e LOG_LEVEL=debug  -p 4822:4822 jumpserver/guacd-dev:main
docker run --rm --name guacd -e LOG_LEVEL=debug -p 4822:4822 guacd-trixie:latest
# docker run --rm --name guacd -e LOG_LEVEL=debug -p 4822:4822 guacamole/guacd:latest
