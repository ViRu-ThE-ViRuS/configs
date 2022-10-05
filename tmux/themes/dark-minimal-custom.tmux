# set default status color
set -g status-style bg=default

# highlight activity in status bar
setw -g window-status-activity-style bg=default
setw -g window-status-activity-style fg="#10c891"

# pane border and colors
set -g clock-mode-colour "#10c891"
set -g clock-mode-style 24

# messages
set -g message-style bg=default
set -g message-style fg="#10c891"

# message command
set -g message-command-style bg=default
set -g message-command-style fg="#10c891"

# modes
set -g mode-style bg=default
set -g mode-style fg="#10c891"

# status bar right
set -g status-right-style none
set -g status-right '#[fg=#999999]{#[fg=#10c891,bold]vir#[fg=#999999]@#(whoami)}'

# background window tab
set-window-option -g window-status-style none
set-window-option -g window-status-format '#[fg=#999999,bg=#383838] #{window_id}_#W #[default]'

# foreground window tab
set-window-option -g window-status-current-style none
set-window-option -g window-status-current-format '#[fg=#cccccc,bg=#595959] #W #[default]'

# window borders
set -g pane-border-style bg=default
set -g pane-border-style fg="#999999"
set -g pane-active-border-style bg=default
set -g pane-active-border-style fg="#383838"
