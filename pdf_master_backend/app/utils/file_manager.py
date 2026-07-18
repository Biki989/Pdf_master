import os
import uuid
import aiofiles
from fastapi import UploadFile

UPLOAD_DIR = "uploads"
PROCESSED_DIR = "processed"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(PROCESSED_DIR, exist_ok=True)

async def save_upload_file(upload_file: UploadFile) -> str:
    """Saves an uploaded file to the temporary uploads directory."""
    file_extension = os.path.splitext(upload_file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    async with aiofiles.open(file_path, 'wb') as out_file:
        while content := await upload_file.read(1024 * 1024):  # async read chunk
            await out_file.write(content)
            
    return file_path

def get_processed_file_path(extension: str = ".pdf") -> str:
    """Generates a unique path for a processed file."""
    unique_filename = f"processed_{uuid.uuid4()}{extension}"
    return os.path.join(PROCESSED_DIR, unique_filename)

def cleanup_file(file_path: str):
    """Deletes a file if it exists."""
    if os.path.exists(file_path):
        try:
            os.remove(file_path)
        except Exception as e:
            print(f"Error deleting file {file_path}: {e}")
