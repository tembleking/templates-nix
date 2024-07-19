{
  lib,
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
  ];

  networking.hostName = "nixos-gcp";
  time.timeZone = "UTC";
  services.openssh.enable = true;

  users.users.root = {
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAA....  user@nixos"];
  };

  system.stateVersion = "24.05";
}
