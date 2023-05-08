# may fish prompt

a simple and fast prompt for fish shells, made by me, [may](https://github.com/m4rch3n1ng).  
comes with custom-made, fully featured git integration.

## install

install using [fisher](https://github.com/jorgebucaran/fisher)

```sh
$ fisher install m4rch3n1ng/may.fish
```

or manually by copying [functions/fish_prompt.fish](/functions/fish_prompt.fish) to `~/.config/fish/functions/fish_prompt.fish`

## customize

you can customize _colors_, _symbols_ and _text_ by setting global variables in your `config.fish`

```sh
# example
set -g __mayfish_color_dir (set_color magenta)
```

### symbols

the available symbols and their defaults are

```sh
set -g __mayfish_symbol_git_hash ":"
```

### colors

the available colors and their defaults are

```sh
set -g __mayfish_color_tag (set_color normal) # the "$" at the start
set -g __mayfish_color_user (set_color yellow) # the username
set -g __mayfish_color_dir (set_color cyan) # the directory

set -g __mayfish_color_root (set_color -o red) # the username when logged in as root
set -g __mayfish_color_root_tag (set_color -o red) # the "#" at the start when logged in as root

set -g __mayfish_color_git_branch (set_color green) # the git branch / hash / rev
set -g __mayfish_color_git_state (set_color magenta) # the git action (rebase, bisect, merge, cherry-pick, revert, am)
```
