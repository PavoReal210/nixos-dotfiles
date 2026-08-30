# home-manager/utilities/ssh.nix
{config, ...}: {
  # Sops secrets for ssh
  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";
    secrets.github-ssh-key = {
      sopsFile = ../../system/secrets/github-ssh-key.age;
      format = "binary";
    };
    secrets.github-ssh-key-pub = {
      sopsFile = ../../system/secrets/github-ssh-key.pub;
      format = "binary";
    };
  };

  # Move all future configs to the settings here
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      identityFile = config.sops.secrets.github-ssh-key.path;
      identitiesOnly = true;
    };
  };
}
