from fastapi import FastAPI

app = FastAPI()


@app.get("/api/data-service/health")
async def root():
    return {"message": "Data Service"}