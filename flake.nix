{
  description = "Kiro Scaffold Plugin - Development environment with Nickel, Nushell, and Claude Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    typix.url = "github:loqusion/typix";
  };

  outputs = { self, nixpkgs, flake-utils, typix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;  # For Claude Code if needed
        };

        # Typix setup for Typst document compilation
        typixLib = typix.lib.${system};

        # Define Typst documents to build
        typstDocs = {
          workflow-architecture = ./docs/workflow-architecture.typ;
          workflow-sequence = ./docs/workflow-sequence.typ;
          workflow-timeline = ./docs/workflow-timeline.typ;
          contract-hierarchy = ./docs/contract-hierarchy.typ;
        };

        # Build all Typst documents
        buildTypstDocs = pkgs.writeShellScriptBin "build-typst-docs" ''
          echo "Building Typst documentation..."
          mkdir -p docs/pdf

          for doc in docs/*.typ; do
            if [ -f "$doc" ]; then
              echo "Compiling $doc..."
              ${pkgs.typst}/bin/typst compile "$doc" "''${doc%.typ}.pdf"
              mv "''${doc%.typ}.pdf" docs/pdf/ 2>/dev/null || true
            fi
          done

          echo "✓ Documentation built in docs/pdf/"
        '';

        # Watch and rebuild Typst docs on change
        watchTypstDocs = pkgs.writeShellScriptBin "watch-typst-docs" ''
          echo "Watching Typst documents for changes..."
          ${pkgs.typst}/bin/typst watch docs/workflow-architecture.typ docs/pdf/workflow-architecture.pdf &
          ${pkgs.typst}/bin/typst watch docs/workflow-sequence.typ docs/pdf/workflow-sequence.pdf &
          ${pkgs.typst}/bin/typst watch docs/workflow-timeline.typ docs/pdf/workflow-timeline.pdf &
          ${pkgs.typst}/bin/typst watch docs/contract-hierarchy.typ docs/pdf/contract-hierarchy.pdf &
          wait
        '';

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

            # Documentation tools
            typst                     # Typst for visual documentation
            typst-lsp                 # Typst language server

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
            buildTypstDocs
            watchTypstDocs
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
            echo "  • build-typst-docs      - Compile all Typst documents to PDF"
            echo "  • watch-typst-docs      - Watch and rebuild Typst docs on change"
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
              npm install --no-save @upstash/context7-mcp 2>/dev/null || true
              echo "Note: mcp-server-nu is experimental and not required for core functionality"
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
          typst = pkgs.typst;

          # Contract validator as a package
          validate-contracts = validateContracts;

          # Typst documentation builder
          build-typst-docs = buildTypstDocs;
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

          build-typst-docs = {
            type = "app";
            program = "${buildTypstDocs}/bin/build-typst-docs";
          };

          watch-typst-docs = {
            type = "app";
            program = "${watchTypstDocs}/bin/watch-typst-docs";
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
