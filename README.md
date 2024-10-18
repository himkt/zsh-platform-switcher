# zsh-platform-switcher

Switching architecture with cleaning up environment variables with one command.

```shell
[arm64] > use-platform x86_64
[x86_64] > uname -m
x86_64
[x86_64] > use-platform arm64
[arm64] > uname -m
arm64
```

### Pre-requisite

Adding the following code-snippet to your `.zshrc`.
You can customize `PROMPT` (I recommend you to show `current_platform` on your terminal).

```zsh
function current_platform () {
  local platform="$(uname -m)"

  if [ "$platform" = "x86_64" ] ; then
    echo "[\033[1;32m$platform\033[0m]"
  elif [ "$platform" = "arm64" ]; then
    echo "[\033[1;31m$platform\033[0m]"
  fi
}
PROMPT="$(current_platform) > "
```

### Installation

You can use `zsh-platform-switcher` by loading `zsh-platform-switcher.zsh` on your zsh config.
If you can use a package manager like Sheldon:

Sheldon:

```toml
[plugins.zsh-platform-switcher]
github = 'himkt/zsh-platform-switcher'
apply = ['source']
```

### Known issue

https://github.com/himkt/zsh-platform-switcher/issues/1: `exit` does not work correctly. When hitting the enter key twice,
a platform will be silently reverted to `x86_64`.

```zsh
> uname -m  # -> arm64
> use-platform x86_64  # -> change platform to x86_64
> uname -m  # -> x86_64
> exit
> uname -m  # arm64
> uname -m  # x86_64  (!!)
```
