#!/usr/bin/env bash

# Pull out the elasticsearch hostname from the environment variable
STPA=${ELASTICSEARCH_URL#http://}
STPB=${STPA%:9200}
ELK_ES_HOST=${STPB%/}

# Wait for the Elasticsearch container to be ready before starting Kibana.
echo "Stalling for Elasticsearch"
while true; do
  echo "Checking if $ELK_ES_HOST is responsive on port 9200"
  nc -q 1 $ELK_ES_HOST 9200 2>/dev/null && break
  sleep 2
done

echo "Starting Kibana"
/docker-entrypoint.sh kibana
