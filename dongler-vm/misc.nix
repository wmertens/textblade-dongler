# Misc configuration:
{
  # Actually, we don't care about rollback for this VM
  # network.enableRollback = true;

  defaults = {
    programs = {
      # Make sysadminning easier
      bash.enableCompletion = true;
    };

    nix = {
      extraOptions = ''
        auto-optimise-store = true
      '';
    };

    boot.kernelParams = [
      # Don't blank the console screen
      "consoleblank=0"
    ];
  };
}
