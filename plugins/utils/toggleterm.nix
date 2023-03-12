{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.toggleterm;
  helpers = import ../helpers.nix {inherit lib;};
  defs = import ../plugin-defs.nix {inherit pkgs;};
in {
  options = {
    plugins.toggleterm = {
      enable = mkEnableOption "Enable toggleterm";
      package = helpers.mkPackageOption "toggleterm" defs.toggleterm;
    };
  };

  config = mkIf cfg.enable {
    extraPlugins = [cfg.package];
    extraConfigLua = ''
      require('toggleterm').setup()
    '';
  };
}
