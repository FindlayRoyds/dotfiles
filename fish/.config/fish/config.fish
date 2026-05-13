if status is-interactive
    set fish_greeting # no more welcome message

    zoxide init fish | source # make zoxide work

    # vim mode
    # fish_vi_key_bindings # enable vi-mode
    # set -g fish_cursor_default block # block cursor in normal mode
    # set -g fish_cursor_insert line # line cursor in insert mode
    # function fish_mode_prompt; end # disable vi-mode prompt

    # non vim mode
    fish_default_key_bindings # disable vi-mode
    set -g fish_cursor_default line # line cursor

    set -gx EDITOR nvim # Open nvim as editor
    set -gx VISUAL nvim # Open nvim as editor
end
