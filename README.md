# **venv-tools**  

## *@jack-denapoli-analyst*  

### I made this because I didn't want to keep calling each package every time I needed to manually.  

### Bash script automation of creating python venv's with persistent package lists (saved as *.conf files).  

*(Made with Lumo 2.0 Max LLM)*  

## Quick Start

> Single Terminal Install (Tested only on Ubuntu 26.04 so far):  

> > "git clone git@github.com:jack-denapoli-analyst/venv-tools.git ~/venv-tools && \
> > cd ~/venv-tools && \
> > bash bootstrap.sh"  

### List Available .config's  
venv-list  


### Create a venv from an already saved .config  
venv-setup *project_name* conf_name

### Activate Profile
source myproject/bin/activate

### Add a new profile (from cli)
echo "package1 package2 package3" > ~/.venv-configs/newprofile.conf

## Already Inclided example .Conf Profiles
data-science | Time series, ML, data cleaning/processing
ml-training | deep learning
web-dev | web framework stack
automation | scripting + scraping  

Any questions, feel free to send a message. This is really just a tool that I needed in the moment, but decided to push it.  
I'm a perpetual student, so any feedback is also more than welcome. Just be kind!

With all respect,
Jack

