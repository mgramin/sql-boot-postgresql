curl -u admin:admin --request POST \
  --url http://localhost:3000/api/datasources \
  --header 'accept: application/json' \
  --header 'cache-control: no-cache' \
  --header 'content-type: application/json' \
  --data '@grafana_datasource.json'

curl -u admin:admin --request POST \
  --url http://localhost:3000/api/dashboards/db \
  --header 'accept: application/json' \
  --header 'authorization: Basic YWRtaW46YWRtaW4=' \
  --header 'cache-control: no-cache' \
  --header 'content-type: application/json' \
  --data '@grafana_dashboard.json'
