# templates-nix

A collection of Nix flake templates for bootstrapping projects with reproducible development environments.

## Usage

```bash
# Initialize with the default template (base)
nix flake init -t github:tembleking/templates-nix

# Initialize with a specific template
nix flake init -t github:tembleking/templates-nix#python-uv-app
```

All templates include [direnv](https://direnv.net/) integration via `.envrc` for automatic environment activation.

## Templates

| Template | Description |
|---|---|
| `base` (default) | Minimal flake with a dev shell, overlay support, and formatter. Good starting point for any project. |
| `devenv` | Dev shell powered by [devenv](https://devenv.sh/), with overlay support and formatter. |
| `python-uv-app` | Python application using [uv](https://github.com/astral-sh/uv). Builds with `buildPythonApplication`, includes a CLI entry point. |
| `python-uv-lib` | Python library using uv. Builds with `buildPythonPackage`, includes `py.typed` marker and import checks. |
| `python-poetry` | Python application using [Poetry](https://python-poetry.org/) via poetry2nix. Supports DEB/RPM bundling. |
| `rust` | Rust application using `buildRustPackage`. Includes cargo, clippy, rust-analyzer, and rustfmt in the dev shell. |
| `go` | Go application using `buildGoModule`. Includes go, gopls, golangci-lint, and govulncheck in the dev shell. |
| `cpp` | C++ application with CMake. Includes clang-tools in the dev shell. |
| `vm-image-gcp` | NixOS image for Google Cloud Platform using the native nixpkgs image builder (`system.build.images`). Produces a `.raw.tar.gz` ready for GCE upload (x86_64 and aarch64). |
| `vm-image-aws` | NixOS AMI for AWS EC2 using the native nixpkgs image builder (`system.build.images`). Produces a `.vhd` ready for EBS snapshot import (x86_64 and aarch64). |

## Template details

### base

A bare-bones flake with nixpkgs and flake-utils. Provides an empty dev shell and overlay that you fill in as needed. Uses `nixfmt-tree` as the formatter.

### devenv

Same layout as `base`, but the dev shell is built with [devenv](https://devenv.sh/) via `devenv.lib.mkShell`. Configure packages, languages, services, and processes through devenv modules. See the [devenv option reference](https://devenv.sh/reference/options/).

### python-uv-app / python-uv-lib

Both Python UV templates share a similar structure:

```
├── flake.nix
├── package.nix
├── pyproject.toml
├── .envrc
├── .gitignore
└── src/
    └── <package>/
        └── __init__.py
```

- Version and package name are read from `pyproject.toml` via `builtins.fromTOML`.
- The dev shell includes `python3` and `uv`.
- `python-uv-app` uses `buildPythonApplication` and defines a script entry point.
- `python-uv-lib` uses `buildPythonPackage` and includes `pythonImportsCheck`.

### python-poetry

Uses poetry2nix to build a Poetry-managed Python application. Includes bundler support for packaging as DEB or RPM:

```bash
nix build .#deb
nix build .#rpm
```

### rust

Uses `rustPlatform.buildRustPackage` to build a Rust application. Package name and version are read from `Cargo.toml` via `builtins.fromTOML`.

```
├── flake.nix
├── package.nix
├── Cargo.toml
├── Cargo.lock
├── .envrc
├── .gitignore
└── src/
    └── main.rs
```

The dev shell includes `cargo`, `clippy`, `rust-analyzer`, and `rustfmt`.

### go

Uses `buildGoModule` to build a Go application. Builds with CGO disabled and stripped binaries by default.

```
├── flake.nix
├── package.nix
├── go.mod
├── .envrc
├── .gitignore
└── cmd/
    └── app/
        └── main.go
```

The dev shell includes `go`, `gopls`, `golangci-lint`, and `govulncheck`.

### cpp

Uses `stdenv.mkDerivation` with CMake to build a C++ application. Version includes the git commit via `self.shortRev`.

```
├── flake.nix
├── package.nix
├── CMakeLists.txt
├── .envrc
├── .gitignore
└── src/
    └── main.cc
```

The dev shell includes `clang-tools` (clangd, clang-format, etc.) and automatically runs `cmake -S . -B build` on entry via `inputsFrom` and `shellHook`.

### vm-image-gcp

Generates a NixOS image for Google Compute Engine, for both `x86_64-linux` and `aarch64-linux` (T2A/C4A). See [vm-image-gcp/README.md](./vm-image-gcp/README.md) for the full build and deploy workflow.

### vm-image-aws

Generates a NixOS AMI for AWS EC2, for both `x86_64-linux` and `aarch64-linux` (Graviton). See [vm-image-aws/README.md](./vm-image-aws/README.md) for the full build, import and launch workflow.

## Formatting

All templates use `nixfmt-tree` as their formatter:

```bash
nix fmt
```
