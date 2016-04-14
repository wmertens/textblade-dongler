{
  defaults =
    { config, pkgs, ... }:
    {
      deployment = {
        targetEnv = "virtualbox";
        /*virtualbox.memorySize = 2048; # megabytes*/
      };
    };
}
