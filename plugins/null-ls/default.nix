{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.null-ls;
  helpers = import ../helpers.nix {inherit lib;};
in {
  imports = [
    ./servers.nix
  ];

  options.plugins.null-ls = {
    enable = mkEnableOption "null-ls";

    package = mkOption {
      type = types.package;
      default = pkgs.vimPlugins.null-ls-nvim;
      description = "Plugin to use for null-ls";
    };

    debug = mkOption {
      default = null;
      type = with types; nullOr bool;
    };

    sourcesItems = mkOption {
      default = null;
      # type = with types; nullOr (either (listOf str) (listOf attrsOf str));
      type = with types; nullOr (listOf (attrsOf str));
      description = "The list of sources to enable, should be strings of lua code. Don't use this directly";
    };

    # sources = mkOption {
    #   default = null;
    #   type = with types; nullOr attrs;
    # };
  };

  config = let
    options = {
      debug = cfg.debug;
      sources = cfg.sourcesItems;
      on_attach = helpers.mkRaw ''
        function(current_client, bufnr)
          if current_client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = lsp_formatting_group, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = lsp_formatting_group,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(client)
                    return client.name == "null-ls"
                  end,
                })
              end,
            })
          end
        end
      '';
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];

      extraConfigLua = ''
        local null_ls_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})
        require("null-ls").setup(${helpers.toLuaObject options})
      '';
    };
}
