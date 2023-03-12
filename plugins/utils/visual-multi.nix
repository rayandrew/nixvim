{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.visual-multi;
  helpers = import ../helpers.nix {inherit lib;};
in {
  options = {
    plugins.visual-multi = {
      enable = mkEnableOption "Enable visual-multi";
      package = helpers.mkPackageOption "visual-multi" pkgs.vimPlugins.vim-visual-multi;
      mappings = mkOption {
        default = null;
        type = types.nullOr types.attrs;
      };
    };
  };

  config = let
    setupOptions = {
      padding = cfg.padding;
      sticky = cfg.sticky;
      ignore = cfg.ignore;
      toggler = cfg.toggler;
      opleader = cfg.opleader;
      mappings = cfg.mappings;
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];
      globals = {
        VM_Mono_hl = "Substitute";
        VM_Cursor_hl = "IncSearch";
        VM_maps =
          if isNull cfg.mappings
          then null
          else cfg.mappings;
      };
    };
}
