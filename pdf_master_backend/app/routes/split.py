from fastapi import APIRouter, File, UploadFile, HTTPException
import os
import zipfile

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import split_pdf

router = APIRouter()

@router.post("/split-pdf")
async def split_pdf_endpoint(file: UploadFile = File(...)):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
    
    saved_path = None
    split_paths = []
    try:
        saved_path = await save_upload_file(file)
        
        # Use temp dir for split files
        output_dir = os.path.dirname(saved_path)
        split_paths = split_pdf(saved_path, output_dir)
        
        # Zip them together
        zip_path = get_processed_file_path('.zip')
        with zipfile.ZipFile(zip_path, 'w') as zipf:
            for p in split_paths:
                zipf.write(p, os.path.basename(p))
                
        filename = os.path.basename(zip_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if saved_path:
            cleanup_file(saved_path)
        for p in split_paths:
            cleanup_file(p)
