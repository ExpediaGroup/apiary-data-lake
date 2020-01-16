{
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "CloudWatch",
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": ${graph_id},
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "AllStorageTypes"
          },
          "expression": "",
          "highResolution": false,
          "id": "",
          "metricName": "NumberOfObjects",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "A",
          "region": "us-east-1",
          "statistics": [
            "Average"
          ]
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "${title_bucket_name} - number of objects",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
          "aliasColors": {
            "Total": "dark-red"
          },
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "CloudWatch",
          "fill": 1,
          "fillGradient": 0,
          "gridPos": {
            "h": 9,
            "w": 12,
            "x": 12,
            "y": 0
          },
          "id": ${graph_id + 1},
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 1,
          "nullPointMode": "null",
          "options": {
            "dataLinks": []
          },
          "percentage": false,
          "pointradius": 2,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "alias": "IntelligentTieringAStorage",
              "dimensions": {
                "BucketName": "${bucket_name}",
                "StorageType": "IntelligentTieringIAStorage"
              },
              "expression": "",
              "highResolution": false,
              "id": "intelligentA",
              "metricName": "BucketSizeBytes",
              "namespace": "AWS/S3",
              "period": "300",
              "refId": "A",
              "region": "us-east-1",
              "statistics": [
                "Sum"
              ]
            },
            {
              "alias": "StandardStorage",
              "dimensions": {
                "BucketName": "${bucket_name}",
                "StorageType": "StandardStorage"
              },
              "expression": "",
              "highResolution": false,
              "id": "standard",
              "metricName": "BucketSizeBytes",
              "namespace": "AWS/S3",
              "period": "300",
              "refId": "B",
              "region": "us-east-1",
              "statistics": [
                "Sum"
              ]
            },
            {
              "alias": "IntelligentTieringAStorage",
              "dimensions": {
                "BucketName": "${bucket_name}",
                "StorageType": "IntelligentTieringFAStorage"
              },
              "expression": "",
              "highResolution": false,
              "id": "intelligentFA",
              "metricName": "BucketSizeBytes",
              "namespace": "AWS/S3",
              "period": "300",
              "refId": "C",
              "region": "us-east-1",
              "statistics": [
                "Sum"
              ]
            },
            {
              "alias": "Total",
              "dimensions": {},
              "expression": "standard + intelligentFA + intelligentA",
              "highResolution": false,
              "id": "total",
              "metricName": "",
              "namespace": "",
              "period": "",
              "refId": "D",
              "region": "default",
              "statistics": [
                "Average"
              ]
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeRegions": [],
          "timeShift": null,
          "title": "${title_bucket_name} - bucket size by type",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "format": "bytes",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        }