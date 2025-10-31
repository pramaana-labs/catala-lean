#!/usr/bin/env python3
"""
Catala to Lean4 API Server

This server provides an API endpoint to convert Catala code to Lean4 code
using the Catala compiler.
"""

import os
import subprocess
import tempfile
import shutil
from pathlib import Path
from typing import Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(
    title="Catala to Lean4 Converter API",
    description="API to convert Catala code to Lean4 code using the Catala compiler",
    version="1.0.0"
)

# Enable CORS for cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Path to the catala compiler executable (in parent directory)
# Try parent directory first (when running from server/ folder)
CATALA_EXE = Path(__file__).parent.parent / "_build" / \
    "default" / "compiler" / "catala.exe"

# Ensure the compiler exists
if not CATALA_EXE.exists():
    # Try current directory (when running from root)
    CATALA_EXE = Path(__file__).parent / "_build" / \
        "default" / "compiler" / "catala.exe"
    if not CATALA_EXE.exists():
        # Try relative path from current directory
        CATALA_EXE = Path("_build/default/compiler/catala.exe")
        if not CATALA_EXE.exists():
            raise FileNotFoundError(
                f"Catala compiler not found. Searched: {CATALA_EXE}. "
                "Please build it first using: dune build @catala"
            )


# Pydantic models for request/response
class ConvertRequest(BaseModel):
    """Request model for convert endpoint"""
    code: Optional[str] = Field(
        None,
        description="Catala code as string (required if 'file' is not provided)"
    )
    file: Optional[str] = Field(
        None,
        description="Path to Catala file (required if 'code' is not provided)"
    )
    extension: Optional[str] = Field(
        ".catala_en",
        description="File extension hint (default: '.catala_en')"
    )

    class Config:
        schema_extra = {
            "example": {
                "code": "```catala\nscope A:\n  definition x equals 42\n```",
                "extension": ".catala_en"
            }
        }


class ConvertResponse(BaseModel):
    """Response model for convert endpoint"""
    success: bool
    lean_code: Optional[str] = None
    error: Optional[str] = None


class HealthResponse(BaseModel):
    """Response model for health endpoint"""
    status: str
    catala_exe: str


@app.get("/health", response_model=HealthResponse)
async def health():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        catala_exe=str(CATALA_EXE)
    )


@app.post("/convert", response_model=ConvertResponse)
async def convert(request: ConvertRequest):
    """
    Convert Catala code to Lean4 code

    - **code**: Catala code as string (provide this OR file)
    - **file**: Path to Catala file (provide this OR code)
    - **extension**: File extension hint (optional, default: '.catala_en')

    Returns the converted Lean4 code.
    """
    try:
        # Validate that either code or file is provided
        if not request.code and not request.file:
            raise HTTPException(
                status_code=400,
                detail="Either 'code' or 'file' must be provided"
            )

        # Determine file extension
        file_ext = request.extension or ".catala_en"
        if not file_ext.startswith("."):
            file_ext = "." + file_ext

        # Create temporary files
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir_path = Path(tmpdir)

            if request.file:
                # File path provided
                input_file = Path(request.file)
                if not input_file.exists():
                    raise HTTPException(
                        status_code=404,
                        detail=f"File not found: {input_file}"
                    )
                # Copy to temp directory to avoid path issues
                temp_input = tmpdir_path / input_file.name
                shutil.copy(input_file, temp_input)
            else:
                # Code provided directly
                if not request.code:
                    raise HTTPException(
                        status_code=400,
                        detail="Code cannot be empty"
                    )
                # Write code to temporary file
                temp_input = tmpdir_path / f"input{file_ext}"
                temp_input.write_text(request.code, encoding="utf-8")

            # Output file
            temp_output = tmpdir_path / "output.lean"

            # Build command
            cmd = [
                str(CATALA_EXE.absolute()),
                "lean4-desugared",
                "--no-stdlib",
                str(temp_input),
                "-o",
                str(temp_output)
            ]

            # Run the compiler from the project root (parent of server/)
            project_root = Path(__file__).parent.parent
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=project_root
            )

            if result.returncode != 0:
                return ConvertResponse(
                    success=False,
                    error=f"Compiler error: {result.stderr}",
                    lean_code=None
                )

            # Read the output Lean file
            if not temp_output.exists():
                return ConvertResponse(
                    success=False,
                    error="Output file was not created",
                    lean_code=None
                )

            lean_code = temp_output.read_text(encoding="utf-8")

            return ConvertResponse(
                success=True,
                lean_code=lean_code,
                error=None
            )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )


@app.get("/")
async def root():
    """API information and documentation"""
    return {
        "name": "Catala to Lean4 Converter API",
        "version": "1.0.0",
        "description": "API to convert Catala code to Lean4 code",
        "endpoints": {
            "GET /health": "Health check endpoint",
            "POST /convert": "Convert Catala code to Lean4",
            "GET /": "This information",
            "GET /docs": "Interactive API documentation (Swagger UI)",
            "GET /redoc": "Alternative API documentation (ReDoc)"
        },
        "interactive_docs": {
            "swagger": "/docs",
            "redoc": "/redoc"
        }
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 5000))
    print(f"Starting Catala to Lean4 API server on port {port}")
    print(f"Catala compiler: {CATALA_EXE}")
    print(f"API documentation available at: http://localhost:{port}/docs")
    uvicorn.run(app, host="0.0.0.0", port=port)
