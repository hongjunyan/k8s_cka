# FastAPI Docker

A backend image for testing ingress path rule

## Usage
- Build Image and push to dockerHub
```commandline
$> docker build -t hongjunyan/fastapi_backend:v1 .
$> docker login
$> docker push hongjunyan/fastapi_backend:v1
```

## APIs

- /show_request_url

