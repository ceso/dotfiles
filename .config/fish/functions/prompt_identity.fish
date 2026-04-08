function prompt_identity
    set -l login (prompt_login | string replace -ra '\e\[[0-9;]*m' '')
    echo -n "[$login:"(prompt_pwd)"]"
end
