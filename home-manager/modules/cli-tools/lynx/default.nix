{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    lynx
  ];
  
  # Create lynx configuration file
  home.file.".lynxrc".text = ''
    # Basic settings
    DEFAULT_INDEX_FILE:https://duckduckgo.com
    SHOW_CURSOR:TRUE
    VI_KEYS:TRUE
    
    # Key mappings for Ctrl+D and Ctrl+U scrolling
    KEYMAP:^D:NEXT_PAGE
    KEYMAP:^U:PREV_PAGE
    
    # Character encoding
    CHARACTER_SET:utf-8
    ASSUME_CHARSET:utf-8
    
    # Editor for forms
    EDITOR:vim
    
    # Search settings
    CASE_SENSITIVE_SEARCHING:OFF
    
    # Display settings
    SHOW_DOTFILES:TRUE
    FORCE_HTML_SOURCE_DUMP:FALSE
    
    # Useful for documentation browsing
    BOLD_H1:TRUE
    BOLD_H2:TRUE
    BOLD_NAME_ANCHORS:TRUE
  '';
}
