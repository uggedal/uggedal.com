% Ansible managed systemd user units
% 2016-12-30

Ansible 2.2.0 gained the ability to manage user units. It's not as
straight forward as using the new `user` parameter though. Here is
an example managing a per-user gpg-agent socket:

```yaml
- name: user gpg-agent
  systemd:
    name: gpg-agent.socket
    state: started
    enabled: yes
    user: yes
  become: yes
  become_user: "{{ item.name }}"
  become_method: su
  environment:
    XDG_RUNTIME_DIR: "/run/user/{{ item.uid }}"
  with_items: "{{ users }}"
```

Without the `XDG_RUNTIME_DIR` environment variable set correctly
you'll get the following failure:

> failure 1 running systemctl show for 'gpg-agent.socket':
> Failed to connect to bus: Permission denied.

This example expects a `users` variable looking like:

```yaml
users:
  - name: foo
    uid: 1000
  - name: bar
    uid: 1001
```
