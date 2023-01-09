# ViRu-ThE-ViRuS

my dev setup :) ![SS2.jpg](images/SS2.jpg)

### Setup

- **TERMINAL**: kitty [ + TMUX ]
- **EDITOR**: neovim
- **SHELL**: fish
- **PKGs**: brew
- **DE**: tiles (MacOS)

#### Neovim

everything in this config was added piece wise, based on the explicit need for
something in my workflow. ive spent a lot of time optimizing for:

- speed (startup time ~5ms, lazy loading almost everything)
- no bloat (only features i use regularly)
- custom tooling (to avoid bloat)
- making plugins work nicely together

some of the "big" things i decided to implement on my own:

- statusline (with lsp, git, diagnostics, outline, truncation, +more)
- lsp handlers (qf-list, notifications, multi-file rename, +more)
- terminal api (send commands, toggle, run last, notifications, +more)
- functionality like `OpenInGithub`, open file in `Finder`, toggle buffer maximize +more
- project local settings and commands
- elaborate fully managed dap ui/ux setup

**NOTE:** i recommend using `neovim HEAD` (or at least 0.8+) to keep up with latest
changes.

**To Reproduce**:

- run `update_config.sh` (might require sudo access), to copy over config files
- all plugins and dependencies should be installed on next launch. restart when
  complete

**NOTE:** i recommend using `checkhealth` to make sure everything is setup and
ready to go

##### External Dependencies

- `cppcheck`

##### Project Setup

- **.clang-format**: clang-format config
- **.clang-tidy**: clang-tidy config
- **.flake8**: autopep8/flake8 config
- **pyrightconfig.json**: pyright config
- **.nvimrc.lua**: project local settings

### Scripts

- `source update_config.sh` to update local config
- `source update_repo.sh` to update the repo with latest local config

### Notes

- **tmux**: setup terminfo profile using `tic -x ${HOME}/.config/tmux/terminfo`
- **brew**: packages in `brew_output.txt` & `brew_cask_output.txt`
- **kitty**: setup fonts according to `kitty/kitty.conf`
- **nvim**: use `LuaCacheClear` from impatient.nvim, if startup seems weirdly slow
