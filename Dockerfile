FROM ghcr.io/pjstaab/osmseed-osm-processor:latest
WORKDIR /mnt/data
COPY ./start.sh .
RUN chmod u+x ./start.sh
CMD ./start.sh
