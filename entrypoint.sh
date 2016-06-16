#!/bin/bash
set -e

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

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
  set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
  if [ "$ELASTICSEARCH_URL" ]; then
    sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /opt/kibana/config/kibana.yml
  fi

  set -- gosu kibana tini -- "$@"
fi

exec "$@"
