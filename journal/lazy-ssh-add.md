% Lazy ssh-add
% 2015-11-10

Like most people I used to run [`ssh-add(1)`][ssh-add] to add
keys to the authentication agent from my shell rc file. I got tired
of unlocking my private key every time I booted a new system so I
created the following to lazily initialize it when it's needed:

```sh
_ssh_add() {
	[ "$SSH_CONNECTION" ] && return

	local key=$HOME/.ssh/id_rsa

	ssh-add -l >/dev/null || ssh-add $key
}

ssh() {
	_ssh_add
	command ssh "$@"
}

scp() {
	_ssh_add
	command scp "$@"
}

git() {
	case $1 in
		push|pull|fetch)
			_ssh_add
			;;
	esac

	command git "$@"
}
```

This has been tested on OpenBSD's [`ksh(1)`][ksh], zsh and bash.

For completeness this is how I start [`ssh-agent(1)`][ssh-agent]:

```sh
_ssh_agent() {
	command -v ssh-agent >/dev/null || return
	[ "$SSH_CONNECTION" ] && return

	local info=$HOME/.cache/ssh-agent-info

	[ -f $info ] && . $info >/dev/null

	[ "$SSH_AGENT_PID" ] && kill -0 $SSH_AGENT_PID 2>/dev/null || {
		mkdir -p $(dirname $info)
		ssh-agent >$info
		. $info >/dev/null
	}
}

_ssh_agent
```

[ssh-agent]: http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-agent.1
[ssh-add]: http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-add.1
[ksh]: http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ksh.1
