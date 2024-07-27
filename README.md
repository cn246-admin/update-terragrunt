## Update terragrunt

This script installs (or updates) [terragrunt](https://terragrunt.gruntwork.io).


### Usage
My home directory structure looks like this:
```
$HOME
└─── .local
    ├── bin
    ├── lib
    │   ├── python
    │   ├── shell
    │   └── venv
    ├── man
    │   └── man1
    ├── share
    │   ├── doc
    │   ├── man
    │   └── ykman
    └── src
        ├── aws-cli
        ├── fzf
        └── lesspipe
```

Where `$HOME/.local/bin` is the first or second entry in `$PATH` depending if I'm running homebrew.

If your home directory structure differs, you can edit the variables at the top of the script to match your system.

Just run the script to install or update terragrunt:
```
./update-terragrunt.sh
```

