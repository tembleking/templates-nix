# NixOS AWS EC2 AMI Creation

This project contains the configuration necessary to create a NixOS AMI that can be used on Amazon Web Services (AWS) EC2.

## Prerequisites

1. **Nix**: Ensure you have Nix installed on your machine.
2. **Linux builder**: The image must be built on (or delegated to) a `x86_64-linux` or `aarch64-linux` machine. On macOS, use a remote builder or the `nix.linux-builder` from nix-darwin.
3. **Access to AWS**: You need an AWS account with permissions to use S3 and EC2 (import snapshots and register images).
4. **AWS CLI**: Install the AWS CLI (`nix shell nixpkgs#awscli2`).
5. **vmimport role**: VM Import requires a service role named `vmimport`. See [Required permissions for VM Import/Export](https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role).

## Configuration

The `flake.nix` file contains the main NixOS configuration for creating the AMI.
The additional specific configuration is located in `configuration.nix`.

## Build the Image

To build the image for the current system, run:

```sh
nix build
```

Or pick an architecture explicitly:

```sh
nix build .#packages.x86_64-linux.amazon    # Intel/AMD instances
nix build .#packages.aarch64-linux.amazon   # Graviton instances
```

Alternatively, using `nixos-rebuild`:

```sh
nixos-rebuild build-image --image-variant amazon --flake .#x86_64-linux
```

This will generate a VHD disk image in the `result` directory:

```sh
$ ls -al ./result/*.vhd
-r--r--r-- 1 root root 1234567890 ene  1  1970 ./result/nixos-amazon-image-25.05.20250101.abcdef0-x86_64-linux.vhd
```

## Upload the Image to AWS

### 1. Authenticate with AWS

```sh
aws configure        # or: aws sso login --profile <your-profile>
export AWS_REGION=<your-region>
```

### 2. Upload the Image to S3

```sh
aws s3 cp result/*.vhd s3://<your-bucket>/nixos-image.vhd
```

### 3. Import the Image as an EBS Snapshot

```sh
aws ec2 import-snapshot \
  --description "NixOS image" \
  --disk-container "Format=VHD,UserBucket={S3Bucket=<your-bucket>,S3Key=nixos-image.vhd}"
```

Wait until the import task is `completed` and note the `SnapshotId`:

```sh
aws ec2 describe-import-snapshot-tasks --import-task-ids <import-snap-id> \
  --query 'ImportSnapshotTasks[0].SnapshotTaskDetail.[Status,Progress,SnapshotId]'
```

### 4. Register the AMI

For `x86_64-linux` images (legacy BIOS boot):

```sh
aws ec2 register-image \
  --name my-nixos-image \
  --architecture x86_64 \
  --virtualization-type hvm \
  --ena-support \
  --sriov-net-support simple \
  --boot-mode legacy-bios \
  --root-device-name /dev/xvda \
  --block-device-mappings "DeviceName=/dev/xvda,Ebs={SnapshotId=<snapshot-id>,VolumeType=gp3,DeleteOnTermination=true}"
```

For `aarch64-linux` images use `--architecture arm64 --boot-mode uefi`.

## Launch an EC2 Instance

Now you can launch an instance using the AMI you just registered:

```sh
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t3.medium \
  --key-name <your-key-pair> \
  --security-group-ids <sg-id> \
  --subnet-id <subnet-id>
```

Use a Graviton instance type (e.g. `t4g.medium`) for `arm64` AMIs.

## Access the Instance

Once the instance is running, you can access it via SSH as `root`:

```sh
ssh root@<instance-public-ip>
```

## Additional Notes

* **SSH Configuration**: The EC2 key pair selected at launch is added to `root` automatically through the instance metadata. You can also bake extra keys into `configuration.nix`.
* **Security Groups**: Make sure the instance's Security Group allows inbound SSH (port 22) from your IP.
* **Disk Size**: The root filesystem is resized automatically to the EBS volume size chosen at launch.
* **AWS Permissions**: Ensure your IAM identity can write to the S3 bucket and call `ec2:ImportSnapshot`, `ec2:RegisterImage` and `ec2:RunInstances`.
