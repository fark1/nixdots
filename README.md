<div align="center">
  <img src="repoassets/snowflake.png" width="200" alt="logo" />

  # Fark's  Nix configuration(s)
</div>


<div align "center>


My nix configuration(s) used across machines old new and current, currently theres only nixOS specific configs but in the future ill update it if i get to use nix stuff outside of nixOS, this repository serves as a way to save my configs  if i ever need to bring them up in the future, if you are looking for my spcefic dotfile config, go to https://github.com/fark1/dots-common

my nix config is designed in a way to work alongside that exact repository, also this repo is meant only for  me,and most of the readmes will be made to help future me in setting up a new linux system hence why theres gonna be a installation guide here,and if you are  not me and wanna use my config or wanna learn how i did certain things, go ahead i guess?, not to mention the other motive behind this readme is for beginners to see how to deploy or run a given dotfile workflow via nix.

</div>


# Installation

Once you installed a nix system, either manually, or via the calamares installer you have to git clone the repository, if you havent installed git 



``` bash

nix-shell -p git 
```

then as usual git clone the repository 

```bash

git clone https://github.com/fark1/nixdots.git ~/.config/dots/nixdots
``` 

once you cloned the repo start the bootstrapping script

```bash

./bootstrap <you put your hostname here>

```

you can also run the script by itself, without giving the hostname which then it prompts you to give a hostname, you will ask yourself why is the script asking for a hostname, it uses that hostname to create a folder inside hosts, i did this so i can have modularity  not host specific configurations 

the script git clones the dots-common repo, and moves it in ~/.config/dots if its not already there, which then the stuff in home.nix stows the dotfiles (dots-common) 