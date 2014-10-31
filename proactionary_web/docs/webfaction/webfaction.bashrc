# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# ELLIOTT (elliottwith2ts.com)
alias elliott_env="export RACK_ENV=production && export GEM_HOME=/home/elliott/webapps/elliott/gems && export RUBYLIB=/home/elliott/webapps/elliott/lib && export PATH=/home/elliott/webapps/elliott/bin:$PATH"
alias elliott_log="less /home/elliott/webapps/elliott/nginx/logs/error.log"
alias elliott_clearlog="cat /dev/null > /home/elliott/webapps/elliott/nginx/logs/error.log"

# PROACTIONARY (proactionary.com)
alias proactionary_log="export RACK_ENV=production && export GEM_HOME=/home/elliott/webapps/proactionary/gems && export RUBYLIB=/home/elliott/webapps/proactionary/lib && export PATH=/home/elliott/webapps/proactionary/bin:$PATH"
alias proactionary_log="less /home/elliott/webapps/proactionary/nginx/logs/error.log"
alias proactionary_log="cat /dev/null > /home/elliott/webapps/proactionary/nginx/logs/error.log"
