# COLOUR (base16)

# default statusbar colors
set-option -g status-style "fg=#b4b7b4,bg=#282a2e"

# default window title colors
set-window-option -g window-status-style "fg=#b4b7b4,bg=default"

# active window title colors
set-window-option -g window-status-current-style "fg=#f0c674,bg=default"

# pane border
set-option -g pane-border-style "fg=#282a2e"
set-option -g pane-active-border-style "fg=#373b41"

# right display
set -g status-right-length 100
set -g status-right-style fg=black
set -g status-right-style bold
set -g status-right '#[fg=#999999]{#[fg=#b5bd68]vir#[fg=#999999]::#[fg=#6699cc]brave#[fg=#999999]}'

# message text
set-option -g message-style "fg=#c5c8c6,bg=#282a2e"

# pane number display
set-option -g display-panes-active-colour "#b5bd68"
set-option -g display-panes-colour "#f0c674"

# clock
set-window-option -g clock-mode-colour "#b5bd68"

# copy mode highligh
set-window-option -g mode-style "fg=#b4b7b4,bg=#373b41"

# bell
set-window-option -g window-status-bell-style "fg=#282a2e,bg=#cc6666"
