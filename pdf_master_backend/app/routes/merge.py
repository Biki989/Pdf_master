from fastapi import APIRouter, File, UploadFile, HTTPException
from typing import List
import os

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import merge_pdfs

router = APIRouter()

@router.post("/merge-pdf")
async def merge_pdf_endpoint(files: List[UploadFile] = File(...)):
    if len(files) < 2:
        raise HTTPException(status_code=400, detail="At least two files are required to merge.")
    
    saved_paths = []
    try:
        # Save uploads
        for f in files:
            if not f.filename.endswith('.pdf'):
                raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
            path = await save_upload_file(f)
            saved_paths.append(path)
        
        # Merge
        output_path = get_processed_file_path('.pdf')
        merge_pdfs(saved_paths, output_path)
        
        filename = os.path.basename(output_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # Cleanup original files
        for path in saved_paths:
            cleanup_file(path)
