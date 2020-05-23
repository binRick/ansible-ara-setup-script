#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
[[ -e .venv/bin/activate ]] || python3 -m venv .venv 
if [[ ! -d .ara-web ]]; then
    git clone https://github.com/ansible-community/ara-web .ara-web
    (cd .ara-web && npm install)
fi
API_SERVER=vpn428
source .venv/bin/activate
pip -q install ara ansible==2.8.11

set -x
export ANSIBLE_LOAD_CALLBACK_PLUGINS=1
source <(python3 -m ara.setup.env)

export ARA_API_CLIENT=http
export ARA_API_SERVER="http://localhost:3001"
export ARA_API_USERNAME=api1
export ARA_API_PASSWORD=api1pass1
export ARA_API_TIMEOUT=15
export ARA_DEFAULT_LABELS=dev,deploy
export ARA_IGNORED_FACTS=ansible_env,ansible_all_ipv4_addresses
export ARA_IGNORED_ARGUMENTS=extra_vars,vault_password_files


env|egrep 'ANSIBLE|ARA|VENV|VIRT'|grep action

#curl -vk http://localhost:3001 2>&1 | grep Server: | grep CPython
find .venv/|grep ara/plugins/|grep action

api_cmd_prefix="ssh -tt -L 3001:127.0.0.1:3001 $API_SERVER sudo -u ara -H -n ~ara/.local/bin/"
ara_cmd="ara-manage runserver --force-color -v 2 127.0.0.1:3001"

cmd="${api_cmd_prefix}${api_cmd}"

echo -e "$cmd"

ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook -i localhost, -c local playbooks/test1.yaml -v

echo -e "\n\nssh -L 8000:127.0.0.1:3001 -L 3000:127.0.0.1:3000 $(hostname -f)\n\n"
exit
