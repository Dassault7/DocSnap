# Ansible

Ansible est un outil open-source de gestion de configuration, d'automatisation et de déploiement. Il permet de gérer des systèmes de manière simple, efficace et sans nécessiter d'agent.

## Installation avec `pipx`

__PIPX__ est un outil qui permet d'installer et de gérer des applications Python dans des environnements virtuels isolés. Cela permet de garder les dépendances propres et de ne pas polluer l'environnement système.

Premièrement, installer `pipx` :

### RedHat / CentOS
```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath --force
```

### Debian / Ubuntu
```bash
apt install pipx
pipx ensurepath --force
```

Ensuite, installer `ansible` avec `pipx` :

```bash
pipx install --include-deps ansible
pipx install ansible-lint
```

## Configuration

### Fichier de configuration

Le fichier `ansible.cfg` permet de configurer le comportement d'Ansible. Il est possible de définir des paramètres globaux, des chemins, des plugins, des options de connexion, etc. Voir la [documentation officielle](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) pour plus de détails.

Ce fichier peut être placé dans le répertoire courant, dans le répertoire `/etc/ansible/` ou dans le répertoire `~/.ansible.cfg`.

Le niveau de priorité est le suivant : `./ansible.cfg` > `~/.ansible.cfg` > `/etc/ansible/ansible.cfg`.

Exemple de fichier `ansible.cfg` :

```ini
[defaults]
inventory = inventories/00_inventory.yml
callbacks_enabled = profile_tasks
stdout_callback = yaml
bin_ansible_callbacks = true
host_key_checking = false
collections_paths = ./collections
roles_path = ./roles
...
```

### Dossier d'inventaire

#### Fichier d'inventaire

L'inventaire est un fichier qui contient la liste des machines sur lesquelles Ansible va agir. Il peut être au format __INI__ ou __YAML__. Il est possible de définir des groupes, des variables, des alias, etc.

##### INI

Exemple de fichier d'inventaire `inventories/hosts` :

```ini
[web]
web1
web2

[db]
db1

[dev]
dev1 ansible_host=... ansible_port=... ansible_user=... ansible_ssh_private_key_file=...

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

##### YAML

Exemple de fichier d'inventaire `inventories/00_inventory.yml` :

```yaml 
all:
  children:
    web:
      hosts:
        web1:
        web2:
    db:
      hosts:
        db1:
    dev:
      hosts:
        dev1:
          ansible_host: ...
          ansible_port: ...
          ansible_user: ...
          ansible_ssh_private_key_file: ...
  
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

#### Dossier `group_vars`

Le dossier `group_vars` permet de définir des variables spécifiques à un groupe d'hôtes. Les fichiers doivent être nommés selon le nom du groupe.

Exemple de fichier `group_vars/web.yml` :

```yaml
nginx_version: 1.18.0
```

#### Dossier `host_vars`

Le dossier `host_vars` permet de définir des variables spécifiques à un hôte. Les fichiers doivent être nommés selon le nom de l'hôte.

Exemple de fichier `host_vars/web1.yml` :

```yaml
nginx_port: 80
```
