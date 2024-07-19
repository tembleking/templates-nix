# NixOS GCP VM Image Creation

This project contains the configuration necessary to create a NixOS VM image that can be used on Google Cloud Platform (GCP).

## Prerequisites

1. **Nix**: Ensure you have Nix installed on your machine.
2. **Access to GCP**: You need a GCP account with permissions to create and manage VM images.
3. **Google Cloud SDK**: Install the Google Cloud SDK on your machine to interact with GCP from the command line.

## Configuration

The `flake.nix` file contains the main NixOS configuration for creating the VM image.
The additional specific configuration is located in `configuration.nix`.

## Build the VM Image

To build the VM image, run the following command:

```sh
nix build
```

This will generate a Google Compute image file in the `result` directory.

```sh
$ ls -al ./result/nixos-image-*
-r--r--r-- 1 root root 532979597 ene  1  1970 ./result/nixos-image-24.05.20240717.c716603-x86_64-linux.raw.tar.gz
```

## Upload the Image to GCP

### 1. Authenticate with GCP

```sh
gcloud auth login
gcloud config set project <your-project-id>
```

### 2. Upload the Image to Google Cloud Storage

```sh
gsutil cp result/nixos-image-* gs://<your-bucket>/nixos-image.tar.gz
```

### 3. Create the Image on GCP

```sh
gcloud compute images create my-nixos-image --source-uri=gs://<your-bucket>/nixos-image.tar.gz
```

## Create a VM Instance on GCP

Now you can create a VM instance on GCP using the image you just uploaded:

```sh
gcloud compute instances create my-nix-vm \
  --image=my-nixos-image \
  --image-project=<your-project-id> \
  --machine-type=e2-medium \
  --zone=<your-zone>
```

## Access the VM

Once the instance is created, you can access it via SSH:

```sh
gcloud compute ssh my-nix-vm --zone=<your-zone>
```

## Additional Notes

* **SSH Configuration**: Ensure you have added your SSH public key in the NixOS configuration (`configuration.nix`) to be able to access the VM.
* **GCP Permissions**: Ensure the service account you are using has the necessary permissions to create and manage VM instances and upload files to GCS.

