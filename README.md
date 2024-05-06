# zsh-platform-switcher

### Installation

Sheldon:

```toml
[plugins.zsh-platform-switcher]
github = 'himkt/zsh-platform-switcher'
apply = ['source']
```

### Known issue

`exit` does not work correctly. When hitting the enter key twice,
a platform will be silently reverted to `x86_64`.

```zsh
> uname -m  # -> arm64
> use-platform x86_64  # -> change platform to x86_64
> uname -m  # -> x86_64
> exit
> uname -m  # arm64
> uname -m  # x86_64  (!!)
```
