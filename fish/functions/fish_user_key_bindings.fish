function fish_user_key_bindings
    fzf_key_bindings

    bind \cp fzf-file-widget
    bind \ct fzf-cd-widget
    bind \cr fzf-history-widget

    if bind -M insert > /dev/null 2>&1
        bind -M insert \cp fzf-file-widget
        bind -M insert \ct fzf-cd-widget
        bind -M insert \cr fzf-history-widget
    end
end
