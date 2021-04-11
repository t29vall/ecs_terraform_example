from fastapi import FastAPI

app = FastAPI()


@app.get("/api/analytics-service/health")
async def root():
    return {"message": "Analytics Service"}