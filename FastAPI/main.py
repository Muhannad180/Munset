from fastapi import FastAPI

app = FastAPI() 

@app.get("/")  # requist/ search
def read_root():
    return {"message": "Hello, FastAPI!"} #response