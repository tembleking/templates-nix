# templates-nix

A collection of Nix flake templates for bootstrapping projects with reproducible development environments.

## Usage

```bash
# Initialize with the default template (devenv)
nix flake init -t github:tembleking/templates-nix

# Initialize with a specific template
nix flake init -t github:tembleking/templates-nix#python-uv-app
```

All templates include [direnv](https://direnv.net/) integration via `.envrc` for automatic environment activation.

## Templates

| Template | Description |
|---|---|
| `devenv` (default) | Minimal flake with a dev shell, overlay support, and formatter. Good starting point for any project. |
| `python-uv-app` | Python application using [uv](https://github.com/astral-sh/uv). Builds with `buildPythonApplication`, includes a CLI entry point. |
| `python-uv-lib` | Python library using uv. Builds with `buildPythonPackage`, includes `py.typed` marker and import checks. |
| `python-poetry` | Python application using [Poetry](https://python-poetry.org/) via poetry2nix. Supports DEB/RPM bundling. |
| `rust` | Rust application using `buildRustPackage`. Includes cargo, clippy, rust-analyzer, and rustfmt in the dev shell. |
| `gcp-vm-image` | NixOS image for Google Cloud Platform via nixos-generators. Produces a `.tar.gz` ready for GCE upload. |

## Template details

### devenv

A bare-bones flake with nixpkgs and flake-utils. Provides an empty dev shell and overlay that you fill in as needed.

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

### gcp-vm-image

Generates a NixOS image for Google Compute Engine. See [gcp-vm-image/README.md](./gcp-vm-image/README.md) for the full build and deploy workflow.

## Formatting

All templates use `nixfmt-tree` as their formatter:

```bash
nix fmt
```
