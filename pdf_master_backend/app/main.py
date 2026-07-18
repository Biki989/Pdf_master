from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from app.routes import merge, split, image_to_pdf, compress, rotate, delete_pages

app = FastAPI(title="PDF Master Tools API", version="1.0.0")

# Allow CORS for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create output dirs if they don't exist
os.makedirs("uploads", exist_ok=True)
os.makedirs("processed", exist_ok=True)

# Mount processed directory to serve files for download
app.mount("/files", StaticFiles(directory="processed"), name="files")

# Include routers
app.include_router(merge.router)
app.include_router(split.router)
app.include_router(image_to_pdf.router)
app.include_router(compress.router)
app.include_router(rotate.router)
app.include_router(delete_pages.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to PDF Master Tools API"}
