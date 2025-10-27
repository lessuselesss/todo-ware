{
  description = "Kiro Scaffold Plugin - Development environment with Nickel, Nushell, and Claude Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;  # For Claude Code if needed
        };

        # Claude Code installation script
        claudeCodeInstaller = pkgs.writeShellScriptBin "install-claude-code" ''
          echo "Installing Claude Code..."
          if command -v claude &> /dev/null; then
            echo "✓ Claude Code already installed"
            claude --version
          else
            echo "Installing Claude Code via curl..."
            curl -sSL https://install.claude.sh | sh
          fi
        '';

        # Helper script to validate contracts
        validateContracts = pkgs.writeShellScriptBin "validate-contracts" ''
          echo "Validating Nickel contracts..."
          for contract in .contracts/**/*.ncl; do
            echo "Checking $contract..."
            nickel typecheck "$contract" || exit 1
          done
          echo "✓ All contracts valid"
        '';

        # Helper script to test plugin
        testPlugin = pkgs.writeShellScriptBin "test-plugin" ''
          echo "Testing kiro-scaffold plugin..."

          # Validate contracts
          echo "1. Validating contracts..."
          validate-contracts

          # Test Nushell utilities
          echo "2. Testing Nushell utilities..."
          nu -c "use tools/kiro.nu *; validate-assertion-id 'AUTH-001--A3'"

          echo "✓ Plugin tests passed"
        '';

        # Helper to run quality checks
        qualityCheck = pkgs.writeShellScriptBin "quality-check" ''
          echo "Running quality checks..."
          nu -c "use tools/kiro.nu *; generate-quality-report | to json"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core languages
            nickel                    # Nickel language for contracts
            nushell                   # Nushell for validation scripts

            # Development tools
            git                       # Version control
            jq                        # JSON processing
            yq                        # YAML processing

            # Markdown tools
            marksman                  # Markdown LSP

            # Testing tools
            nodePackages.npm          # For MCP servers (Context7, mcp-server-nu)

            # Custom scripts
            claudeCodeInstaller
            validateContracts
            testPlugin
            qualityCheck
          ];

          shellHook = ''
            echo "🚀 Kiro Scaffold Plugin Development Environment"
            echo ""
            echo "Available tools:"
            echo "  • nickel $(nickel --version 2>&1 | head -n1)"
            echo "  • nushell $(nu --version)"
            echo "  • git $(git --version | cut -d' ' -f3)"
            echo ""
            echo "Custom commands:"
            echo "  • install-claude-code   - Install Claude Code CLI"
            echo "  • validate-contracts    - Type-check all Nickel contracts"
            echo "  • test-plugin           - Run plugin tests"
            echo "  • quality-check         - Generate quality report"
            echo ""
            echo "Quick start:"
            echo "  1. install-claude-code"
            echo "  2. validate-contracts"
            echo "  3. test-plugin"
            echo ""

            # Set up environment variables
            export CLAUDE_PLUGIN_ROOT="$(pwd)"

            # Add MCP servers to PATH
            export PATH="$PATH:$(pwd)/node_modules/.bin"

            # Install MCP dependencies if not present
            if [ ! -d "node_modules" ]; then
              echo "Installing MCP server dependencies..."
              npm install --no-save @upstash/context7-mcp mcp-server-nu
            fi

            echo "Environment ready! 🎉"
          '';

          # Environment variables
          NICKEL_PATH = "${pkgs.nickel}/bin/nickel";
          NUSHELL_PATH = "${pkgs.nushell}/bin/nu";
        };

        # Provide packages for other flakes to use
        packages = {
          nickel = pkgs.nickel;
          nushell = pkgs.nushell;

          # Contract validator as a package
          validate-contracts = validateContracts;
        };

        # Apps that can be run with `nix run`
        apps = {
          validate-contracts = {
            type = "app";
            program = "${validateContracts}/bin/validate-contracts";
          };

          test-plugin = {
            type = "app";
            program = "${testPlugin}/bin/test-plugin";
          };

          quality-check = {
            type = "app";
            program = "${qualityCheck}/bin/quality-check";
          };
        };

        # Checks that run with `nix flake check`
        checks = {
          contracts = pkgs.runCommand "check-contracts" {
            buildInputs = [ pkgs.nickel ];
          } ''
            cd ${./.}
            for contract in .contracts/**/*.ncl; do
              echo "Checking $contract..."
              ${pkgs.nickel}/bin/nickel typecheck "$contract"
            done
            touch $out
          '';

          nushell-syntax = pkgs.runCommand "check-nushell" {
            buildInputs = [ pkgs.nushell ];
          } ''
            cd ${./.}
            # Basic syntax check - Nushell will error on invalid syntax
            ${pkgs.nushell}/bin/nu -c "use tools/kiro.nu *"
            touch $out
          '';
        };
      }
    );
}
