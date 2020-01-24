    {
      "content": "\n# ${title_bucket_name}",
      "datasource": null,
      "gridPos": {
        "h": 2,
        "w": 23,
        "x": 0,
        "y": ${y_position}
      },
      "id": ${graph_id},
      "mode": "markdown",
      "options": {},
      "timeFrom": null,
      "timeShift": null,
      "title": "",
      "type": "text"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorValue": false,
      "colors": [
        "#299c46",
        "rgba(237, 129, 40, 0.89)",
        "#d44a3a"
      ],
      "datasource": "CloudWatch",
      "description": "",
      "format": "bytes",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 9,
        "w": 3,
        "x": 0,
        "y": ${y_position}
      },
      "id": ${graph_id + 1},
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "nullPointMode": "connected",
      "nullText": null,
      "options": {},
      "pluginVersion": "6.4.2",
      "postfix": "",
      "postfixFontSize": "100%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false,
        "ymax": null,
        "ymin": null
      },
      "tableColumn": "",
      "targets": [
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "IntelligentTieringFAStorage"
          },
          "expression": "",
          "hide": true,
          "highResolution": false,
          "id": "a",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "A",
          "region": "${aws_region}",
          "statistics": [
            "Maximum"
          ]
        },
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "IntelligentTieringIAStorage"
          },
          "expression": "",
          "hide": true,
          "highResolution": false,
          "id": "b",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "B",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        },
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "StandardStorage"
          },
          "expression": "",
          "hide": true,
          "highResolution": false,
          "id": "c",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "C",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        },
        {
          "alias": "Total in TiB",
          "dimensions": {},
          "expression": "a+b+c",
          "hide": false,
          "highResolution": false,
          "id": "d",
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
      "thresholds": "",
      "timeFrom": null,
      "timeShift": null,
      "title": "Total Bucket Size",
      "type": "singlestat",
      "valueFontSize": "100%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        },
        {
          "op": "=",
          "text": "",
          "value": ""
        }
      ],
      "valueName": "current"
    },
    {
      "aliasColors": {},
      "breakPoint": "50%",
      "cacheTimeout": null,
      "combine": {
        "label": "Others",
        "threshold": 0
      },
      "datasource": "CloudWatch",
      "description": "",
      "fontSize": "80%",
      "format": "short",
      "gridPos": {
        "h": 9,
        "w": 5,
        "x": 3,
        "y": ${y_position}
      },
      "id": ${graph_id + 2},
      "interval": null,
      "legend": {
        "percentage": true,
        "show": true,
        "values": false
      },
      "legendType": "Under graph",
      "links": [],
      "maxDataPoints": 3,
      "nullPointMode": "connected",
      "options": {},
      "pieType": "pie",
      "pluginVersion": "6.4.2",
      "strokeWidth": 1,
      "targets": [
        {
          "alias": "IntelligentTieringFAStorage",
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "IntelligentTieringFAStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "a",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "A",
          "region": "${aws_region}",
          "statistics": [
            "Maximum"
          ]
        },
        {
          "alias": "IntelligentTieringIAStorage",
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "IntelligentTieringIAStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "b",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "B",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        },
        {
          "alias": "StandardStorage",
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "StandardStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "c",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "C",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Bucket Size By Tier",
      "type": "grafana-piechart-panel",
      "valueName": "current"
    },
    {
      "aliasColors": {},
      "bars": false,
      "cacheTimeout": null,
      "dashLength": 10,
      "dashes": false,
      "datasource": "CloudWatch",
      "description": "",
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 11,
        "x": 8,
        "y": ${y_position}
      },
      "id": ${graph_id + 3},
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
      "links": [],
      "nullPointMode": "connected",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pluginVersion": "6.4.2",
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
            "StorageType": "IntelligentTieringFAStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "a",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "A",
          "region": "${aws_region}",
          "statistics": [
            "Maximum"
          ]
        },
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "IntelligentTieringIAStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "b",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "B",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        },
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "StandardStorage"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "c",
          "metricName": "BucketSizeBytes",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "C",
          "region": "${aws_region}",
          "statistics": [
            "Average"
          ]
        },
        {
          "alias": "Total in TiB",
          "dimensions": {},
          "expression": "a+b+c",
          "hide": false,
          "highResolution": false,
          "id": "d",
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
      "title": "Total Bucket Size",
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
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorValue": false,
      "colors": [
        "#299c46",
        "rgba(237, 129, 40, 0.89)",
        "#d44a3a"
      ],
      "datasource": "CloudWatch",
      "description": "",
      "format": "short",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": false,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 9,
        "w": 4,
        "x": 19,
        "y": ${y_position}
      },
      "id": ${graph_id + 4},
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "nullPointMode": "connected",
      "nullText": null,
      "options": {},
      "pluginVersion": "6.4.2",
      "postfix": "",
      "postfixFontSize": "100%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false,
        "ymax": null,
        "ymin": null
      },
      "tableColumn": "",
      "targets": [
        {
          "dimensions": {
            "BucketName": "${bucket_name}",
            "StorageType": "AllStorageTypes"
          },
          "expression": "",
          "hide": false,
          "highResolution": false,
          "id": "a",
          "metricName": "NumberOfObjects",
          "namespace": "AWS/S3",
          "period": "300",
          "refId": "A",
          "region": "${aws_region}",
          "statistics": [
            "Maximum"
          ]
        }
      ],
      "thresholds": "",
      "timeFrom": null,
      "timeShift": null,
      "title": "Total Number of Objects in Bucket",
      "type": "singlestat",
      "valueFontSize": "100%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        },
        {
          "op": "=",
          "text": "",
          "value": ""
        }
      ],
      "valueName": "current"
    }