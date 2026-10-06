# NixOS GCP VM Image Creation

This project contains the configuration necessary to create a NixOS VM image that can be used on Google Cloud Platform (GCP).

## Prerequisites

1. **Nix**: Ensure you have Nix installed on your machine.
2. **Linux builder**: The image must be built on (or delegated to) a `x86_64-linux` or `aarch64-linux` machine. On macOS, use a remote builder or the `nix.linux-builder` from nix-darwin.
3. **Access to GCP**: You need a GCP account with permissions to create and manage VM images.
4. **Google Cloud SDK**: Install the Google Cloud SDK (`nix shell nixpkgs#google-cloud-sdk`).

## Configuration

The `flake.nix` file contains the main NixOS configuration for creating the VM image.
The additional specific configuration is located in `configuration.nix`.

## Build the VM Image

To build the VM image for the current system, run:

```sh
nix build
```

Or pick an architecture explicitly:

```sh
nix build .#packages.x86_64-linux.gce    # x86_64 machine types (E2, N2, C3...)
nix build .#packages.aarch64-linux.gce   # Arm machine types (T2A, C4A...)
```

Alternatively, using `nixos-rebuild`:

```sh
nixos-rebuild build-image --image-variant google-compute --flake .#x86_64-linux
```

This will generate a Google Compute image file in the `result` directory.

```sh
$ ls -al ./result/*.raw.tar.gz
-r--r--r-- 1 root root 532979597 ene  1  1970 ./result/nixos-image-google-compute-25.05.20250101.abcdef0-x86_64-linux.raw.tar.gz
```

## Upload the Image to GCP

### 1. Authenticate with GCP

```sh
gcloud auth login
gcloud config set project <your-project-id>
```

### 2. Upload the Image to Google Cloud Storage

```sh
gcloud storage cp result/*.raw.tar.gz gs://<your-bucket>/nixos-image.tar.gz
```

### 3. Create the Image on GCP

For `x86_64-linux` images:

```sh
gcloud compute images create my-nixos-image \
  --source-uri=gs://<your-bucket>/nixos-image.tar.gz \
  --architecture=X86_64 \
  --guest-os-features=GVNIC
```

For `aarch64-linux` images (UEFI is enabled by default in `configuration.nix`):

```sh
gcloud compute images create my-nixos-image-arm64 \
  --source-uri=gs://<your-bucket>/nixos-image.tar.gz \
  --architecture=ARM64 \
  --guest-os-features=UEFI_COMPATIBLE,GVNIC
```

If you enable `virtualisation.googleComputeImage.efi` on x86_64, add `UEFI_COMPATIBLE` there too.

## Create a VM Instance on GCP

Now you can create a VM instance on GCP using the image you just uploaded:

```sh
gcloud compute instances create my-nix-vm \
  --image=my-nixos-image \
  --image-project=<your-project-id> \
  --machine-type=e2-medium \
  --zone=<your-zone>
```

Use an Arm machine type (e.g. `t2a-standard-1`) for `ARM64` images.

## Access the VM

Once the instance is created, you can access it via SSH:

```sh
gcloud compute ssh my-nix-vm --zone=<your-zone>
```

## Additional Notes

* **SSH Configuration**: SSH keys from project/instance metadata and OS Login are managed by the Google guest agent, so `gcloud compute ssh` works out of the box. You can also bake extra keys into `configuration.nix`.
* **Firewall**: Make sure the VPC firewall rules allow inbound SSH (port 22) to the instance.
* **Disk Size**: The root filesystem is resized automatically to the persistent disk size chosen at creation time.
* **GCP Permissions**: Ensure the account you are using has the necessary permissions to create and manage VM instances and images, and to upload files to GCS.
