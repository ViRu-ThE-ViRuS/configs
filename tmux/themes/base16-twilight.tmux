# COLOUR (base16)

# default statusbar colors
set-option -g status-style "fg=#838184,bg=#323537"

# default window title colors
set-window-option -g window-status-style "fg=#838184,bg=default"

# active window title colors
set-window-option -g window-status-current-style "fg=#f9ee98,bg=default"

# pane border
set-option -g pane-border-style "fg=#323537"
set-option -g pane-active-border-style "fg=#464b50"

# right display
set -g status-right-length 100
set -g status-right-style fg=black
set -g status-right-style bold
set -g status-right '#[fg=#999999]{#[fg=#b5bd68]vir#[fg=#999999]::#[fg=#6699cc]brave#[fg=#999999]}'

# message text
set-option -g message-style "fg=#a7a7a7,bg=#323537"

# pane number display
set-option -g display-panes-active-colour "#8f9d6a"
set-option -g display-panes-colour "#f9ee98"

# clock
set-window-option -g clock-mode-colour "#8f9d6a"

# copy mode highligh
set-window-option -g mode-style "fg=#838184,bg=#464b50"

# bell
set-window-option -g window-status-bell-style "fg=#323537,bg=#cf6a4c"
