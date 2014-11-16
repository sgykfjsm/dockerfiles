# docker_tdd

tdd on Vagrant with Serverspec + Docker

## outline

```
Mac --> ssh --> Vagrant(ubuntu) --> docker exec by serverspec --> docker-container
```

## Includings

- base
  - simple Ubuntu Image
- jruby
  - include jruby-1.7.16 and rbenv on sgykfjsm/base\_ubuntu
- nginx\_php
  - include nginx + php5-fpm on sgykfjsm/php5fpm
- nginx\_simple
  - include nginx on sgykfjsm/base
- norikra
  - include [norikra](http://norikra.github.io/) on sgykfjsm/jruby
- openrestry
  - include [openresty](http://openresty.org/) on sgykfjsm/base\_ubuntu
- php5fpm
  - include php5-fpm on sgykfjsm/base\_ubuntu
- ruby
  - include ruby 2.1.4 on sgykfjsm/base\_ubuntu
- td-agent
  - include td-agent on sgykfjsm/base\_ubuntu


## setup

### Install ruby

+ `rvm seppuku`
+ `rm -rf ~./rvm ~/.rmv`
+ `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"`
+ `brew doctor`
+ `brew update && brew upgrade`
+ `brew install rbenv ruby-build rbenv-gemset rbenv-gem-rehash readline apple-gcc42`
+ `rm -rf ~/.rbenv/plugins/ruby-build`
+ `git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build`
+ `rbenv install 2.1.4`
+ `rbenv rehash`
+ `rbenv global 2.1.4`

### Install Serverspec

+ `gem install serverspec`
+ `gem install docker-api`

### Install Vagrant

+ [Download](https://www.virtualbox.org/wiki/Downloads) & Install VitualBox
+ [Download](https://www.vagrantup.com/downloads) & Install Vagrant
+ `vagrant plugin install vagrant-vbguest`
+ `vagrant plugin install vagrant-cachier`
+ [Check Official Latest Stable ubuntu box](http://www.vagrantbox.es/) && `vagrant box add {title} {box-url}`

## Begin

+ Clone this repo.
+ Change `config.vm.box_url` to your box-path in ${repo_path}/Vagrantfile
+ `vagrant up`
+ If `vagrant up` is OK, logout vagrant and `serverspec-init`
  - FYI: [http://serverspec.org/](http://serverspec.org/)
+ execute testing: `bash ${repo-path}/do_spec`
