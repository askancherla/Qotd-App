# API

Sometimes it is useful to invoke the Anomaly Generator functionality via an API.  

This API, like the Anomaly Generator UI itself is not secure.  There is no user management.  Not even TLS is used.  If you need such functionality then you will have to create a reverse proxy with something like Nginx and use it to manage user credentials.

## GET /version

Returns the version of the running instance.

**Sample output**
```
qotd-usecase-generator v5.0.0, build: build-840017378
.  Your IP: 71.162.242.116
```

## POST /reset

Turns off all active anomalies.  Payload is not required.

**Sample CURL***
```bash
curl -X POST http://example.com/reset 
```

## POST /activate/:id

Starts an anomaly scenario. You must pass in the JSON object `{"action": "start"}`.  This is a legacy requirement from previous versions. Soon it will not be required.  The `:id` is the ID of the use case scenario to start.

Content-Type: application/json

**Sample CURL**
```bash
curl POST http://example.com/activate/1_cert_warning -H "Content-Type: application/json" -d '{"action": "start"}'

```

## GET /usecase

Returns a list of all defined scenarios. 

**Sample output**

`GET http://example.com/usecase`
```JSON
[
    {
        "id": "1_cert_warning",
        "name": "Image service logs indicate certificate is about to expire.",
        "description": "The certificate for the image service will expire soon. Unless dealt with the failure will cause lots of problems.",
        "status": ""
    },
    {
        "id": "2_cert_failure",
        "name": "Image service cert expires, Author service unable to connect to ratings.",
        "description": "The ratings service is unaccessible because cert expired.",
        "status": ""
    },
    {
        "id": "a_cascade_failure",
        "name": "Quote, PDF, Web, Rating service cascade failure",
        "description": "This use case simulates a failure beginning in the quote service.  Later the failures cascade to pdf, ratings and web services.  ",
        "status": ""
    },
    {
        "id": "b_ratings",
        "name": "Ratings service failures",
        "description": "The rating service experiences major problems across the board (log anomalies, latency, cpu, memory and increase of error status codes).",
        "status": ""
    },
    {
        "id": "c_quote_pdf_issues",
        "name": "Quote and PDF Service Issues",
        "description": "New log entries are added to quote and pdf services. Both also experience sharp increase in CPU and memory.",
        "status": ""
    },
    {
        "id": "d_jserr_id",
        "name": "JS Error",
        "description": "Initiates a JS error in the order page.",
        "status": ""
    }
]
```

## GET /usecase/:id

Accept: application/json

**Sample output**

`GET http://example.com/usecase/1_cert_warning`

```json
{
    "id": "1_cert_warning",
    "name": "Image service logs indicate certificate is about to expire.",
    "description": "The certificate for the image service will expire soon. Unless dealt with the failure will cause lots of problems.",
    "steps": [
        {
            "service": "image",
            "name": "Log warnings indicate that cert will expire soon.",
            "type": "setLogger",
            "options": {
                "name": "Log warning of cert to expire.",
                "template": "WARNING: service certificate expiration imminent.  Please update certificates.",
                "fields": {},
                "repeat": {
                    "mean": 20000,
                    "stdev": 1000,
                    "min": 5000,
                    "max": 30000
                }
            }
        }
    ]
}
```

## DELETE /usecase/:id

Removes the active scenario with the given id

## POST /usecase

Content-Type: application/json

Body is JSON of a scenario

## PUT /usecase/:id

Content-Type: application/json

Body is JSON of a scenario that already exists.  The ID in teh body must match an existing scenario, and be the last segment in the URL.


