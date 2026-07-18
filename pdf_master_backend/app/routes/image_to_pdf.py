from fastapi import APIRouter, File, UploadFile, HTTPException
from typing import List
import os

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import images_to_pdf

router = APIRouter()

@router.post("/image-to-pdf")
async def image_to_pdf_endpoint(files: List[UploadFile] = File(...)):
    if not files:
        raise HTTPException(status_code=400, detail="At least one image file is required.")
        
    saved_paths = []
    try:
        # Save uploads
        for f in files:
            ext = f.filename.lower()
            if not ext.endswith(('.png', '.jpg', '.jpeg')):
                raise HTTPException(status_code=400, detail="Only PG and PNG files are allowed.")
            path = await save_upload_file(f)
            saved_paths.append(path)
        
        # Convert
        output_path = get_processed_file_path('.pdf')
        images_to_pdf(saved_paths, output_path)
        
        filename = os.path.basename(output_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        for path in saved_paths:
            cleanup_file(path)
