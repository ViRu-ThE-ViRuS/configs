# COLOUR (base16)

# default statusbar colors
set-option -g status-style "fg=#bdae93,bg=#3c3836"

# default window title colors
set-window-option -g window-status-style "fg=#bdae93,bg=default"

# active window title colors
set-window-option -g window-status-current-style "fg=#fabd2f,bg=default"

# pane border
set-option -g pane-border-style "fg=#3c3836"
set-option -g pane-active-border-style "fg=#504945"

# right display
set -g status-right-length 100
set -g status-right-style fg=black
set -g status-right-style bold
set -g status-right '#[fg=#999999]{#[fg=#b5bd68]vir#[fg=#999999]::#[fg=#6699cc]brave#[fg=#999999]}'

# message text
set-option -g message-style "fg=#d5c4a1,bg=#3c3836"

# pane number display
set-option -g display-panes-active-colour "#b8bb26"
set-option -g display-panes-colour "#fabd2f"

# clock
set-window-option -g clock-mode-colour "#b8bb26"

# copy mode highligh
set-window-option -g mode-style "fg=#bdae93,bg=#504945"

# bell
set-window-option -g window-status-bell-style "fg=#3c3836,bg=#fb4934"
