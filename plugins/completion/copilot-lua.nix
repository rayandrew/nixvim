{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.copilot-lua;
  cfg-copilot-vim = config.plugins.copilot;
  helpers = import ../helpers.nix {inherit lib;};
in {
  options = {
    plugins.copilot-lua = {
      enable = mkEnableOption "copilot-lua";
      package = helpers.mkPackageOption "copilot-lua" pkgs.vimPlugins.copilot-lua;
      filetypes = mkOption {
        type = types.attrsOf types.bool;
        description = "A dictionary mapping file types to their enabled status";
        default = {};
        example = literalExpression ''          {
                    "*": false,
                    python: true
                  }'';
      };

      suggestion = mkOption {
        default = null;
        type = types.nullOr (types.attrsOf (types.oneOf [
          types.bool
          types.attrs
        ]));
      };

      server_opts_overrides = mkOption {
        default = null;
        type = types.nullOr types.attrs;
      };
    };
  };

  config = let
    options = {
      filetypes = cfg.filetypes;
      suggestion = cfg.suggestion;
      copilot_node_command = "${pkgs.nodejs-16_x}/bin/node";
    };
  in
    mkIf (cfg.enable && !cfg-copilot-vim.enable) {
      extraPlugins = [cfg.package];
      extraConfigLua = ''
        do
          vim.defer_fn(function()
            require('copilot').setup(${helpers.toLuaObject options})
          end, 100)
        end
      '';
    };
}
