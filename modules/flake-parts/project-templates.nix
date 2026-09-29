let
  # Starting points for my projects: a flake with a development shell, an
  # .envrc for direnv, and a .gitignore. In a new project folder:
  #
  #   nix flake init -t ~/personal/nix#go      (or #php, #node, #rust, #odin)
  #   direnv allow
  #
  # The files are in templates/projects/<name>/; each project then owns its
  # copy and pins its own tools in its flake.lock.
  template = name: description: {
    path = ../../templates/projects + "/${name}";
    inherit description;
  };
in
{
  flake.templates = {
    default = template "default" "A project with a development shell (add its tools)";
    go = template "go" "Go, with air for live reload and golangci-lint";
    php = template "php" "PHP 8.5 with Composer";
    node = template "node" "Node.js with pnpm";
    rust = template "rust" "Rust from nixpkgs: cargo, rustc, clippy, rustfmt, rust-analyzer";
    odin = template "odin" "Odin with its language server (ols)";
  };
}
