from typing import Union
from fastapi import FastAPI, Request
import uvicorn
from redis import Sentinel

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}

@app.get("/show_request")
def show_request(request: Request):
    client_host = request.client.host
    return {"client_host": client_host}

@app.get("/show_uid")
def show_uid(request: Request, uid):
    client_host = request.client.host
    return {"client_host": client_host, "uid": uid}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)