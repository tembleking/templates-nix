{
  lib,
  pkgs,
  config,
  ...
}: {
  # You can see all the available options at: https://search.nixos.org/options

  # Add overlays
  # nixpkgs.overlays = []

  # Specify additional system packages to be installed.
  environment.systemPackages = with pkgs; [
    # Add any packages you want to be available in the system by default here.
    # For example: wget, vim, git
    # You can see all the available packages at: https://search.nixos.org/packages
  ];

  # Enable flakes.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Set the hostname for the machine.
  networking.hostName = "nixos-gcp";

  # Set the timezone for the system.
  time.timeZone = "UTC";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH service to allow SSH access to the machine.
  services.openssh.enable = true;

  # Configure the root user.
  users.users.root = {
    # Add the public SSH key for the root user to allow SSH access.
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAA....  user@nixos"];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
