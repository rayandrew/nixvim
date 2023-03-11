{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.copilot-lua-cmp;
  cfg-copilot-lua = config.plugins.copilot-lua;
  cfg-cmp = config.plugins.nvim-cmp;
  helpers = import ../helpers.nix {inherit lib;};
  defs = import ../plugin-defs.nix {inherit pkgs;};
in {
  options = {
    plugins.copilot-lua-cmp = {
      enable = mkEnableOption "copilot-lua-cmp";
      package = helpers.mkPackageOption "copilot-lua-cmp" defs.copilot-cmp;
    };
  };

  config = mkIf (cfg.enable && cfg-copilot-lua.enable && (helpers.isTruthy cfg-cmp.enable)) {
    extraPlugins = [cfg.package];
    extraConfigLua = ''
      do
        require('copilot_cmp').setup()
      end
    '';
  };
}
