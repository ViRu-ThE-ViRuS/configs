function fish_user_key_bindings
  fzf_key_bindings

  bind \cp fzf-cd-widget
  if bind -M insert > /dev/null 2>&1
    bind -M insert \cp fzf-cd-widget
  end
end
