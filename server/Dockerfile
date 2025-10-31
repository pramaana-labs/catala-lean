# Dockerfile for Catala to Lean4 API Server (GCP Cloud Run)
# Optimized version using pre-built catala package from OPAM
# Build context should be the parent directory (catala-lean/)
# Build for linux/amd64 platform for Cloud Run compatibility

# Stage 1: Install Catala from OPAM and build lean4-desugared plugin
FROM ocamlpro/ocaml:4.14-2025-07-27 AS builder

WORKDIR /app

# Install system dependencies
RUN sudo apk add openjdk21 bash curl python3 py3-pip

# Setup OPAM with OCaml 4.14.2 (similar to local setup)
RUN opam init --disable-sandboxing -y && \
    opam switch create 4.14.2 || opam switch set 4.14.2 && \
    eval $(opam env)

# Copy opam files first (needed to install dependencies)
COPY *.opam ./
COPY dune dune-project ./

# Install catala dependencies from OPAM (FAST - pre-built packages)
# This installs dune and all other dependencies
RUN eval $(opam env) && \
    opam update && \
    opam install . --deps-only -y

# Copy remaining source files needed to build the lean4-desugared plugin
# We need: compiler source, stdlib, deps, runtimes, and syntax_highlighting
# Fix ownership immediately after COPY to ensure we can write to /app
COPY compiler/ compiler/
COPY stdlib/ stdlib/
COPY deps/ deps/
COPY runtimes/ runtimes/
COPY syntax_highlighting/ syntax_highlighting/
COPY Makefile ./
COPY runtimes/python/pyproject.toml runtimes/python/pyproject.toml
COPY deps/dates-calc/lib_python/pyproject.toml deps/dates-calc/lib_python/pyproject.toml

# Fix ownership of /app to current user so we can write _build directory
RUN sudo chown -R $(id -u):$(id -g) /app

# Install Python dependencies needed for syntax highlighting
# (required by literate module which is a dependency)
# The lexer.py files need to be accessible, installing pygments packages makes them available
# Using --break-system-packages flag is safe in Docker containers
RUN eval $(opam env) && \
    python3 -m pip install -U pip --break-system-packages && \
    python3 -m pip install --break-system-packages -e syntax_highlighting/en/pygments -e syntax_highlighting/fr/pygments -e syntax_highlighting/pl/pygments && \
    opam exec -- make dependencies-python pygments || true

# Build catala compiler and the lean4-desugared plugin
# Building from source ensures compatibility with container's architecture and libraries
# Use opam exec to ensure dune from OPAM is used
# Ensure ownership is correct before building (Python install may have created files)
RUN sudo chown -R $(id -u):$(id -g) /app && \
    eval $(opam env) && \
    opam exec -- dune build @catala && \
    opam exec -- dune build compiler/plugins/lean4_desugared.cmxs

# Copy the built catala executable
RUN cp /app/_build/default/compiler/catala.exe /app/catala.exe && \
    chmod +x /app/catala.exe

# Stage 2: Runtime image with Python API
# Use Alpine-based Python to match the builder's musl libc
FROM python:3.11-alpine

WORKDIR /app

# Install system dependencies for Catala runtime
# OCaml runtime needs these libraries
RUN apk add --no-cache \
        bash \
        curl \
        ca-certificates \
        gmp \
        libffi \
        gcc \
        musl-dev

# Copy catala executable and plugin from builder (built for Alpine/musl)
COPY --from=builder /app/catala.exe /app/catala.exe
COPY --from=builder /app/_build/default/compiler/plugins/lean4_desugared.cmxs /app/lean4_desugared.cmxs

# Verify the binary works and show its dependencies
RUN ldd /app/catala.exe 2>/dev/null || echo "Binary is statically linked or ldd not available"

# Copy Python requirements and install
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy API server
COPY server/api_server.py .

# Create directory structure for compiler and plugins
RUN mkdir -p _build/default/compiler/plugins && \
    mv /app/catala.exe _build/default/compiler/catala.exe && \
    cp /app/lean4_desugared.cmxs _build/default/compiler/plugins/lean4_desugared.cmxs && \
    chmod +x _build/default/compiler/catala.exe

# Cloud Run sets PORT environment variable
ENV PORT=8080

# Expose port (Cloud Run will override this)
EXPOSE 8080

# Run the API server
CMD ["python3", "api_server.py"]
