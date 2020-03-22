# Iterate over all users
{% for name, user in pillar.get('users', {}).items() if user.absent is not defined or not user.absent %}
{%- if user == None -%}
{%- set user = {} -%}
{%- endif -%}
#set the userfiles
{%- set user_files = salt['pillar.get'](('users:' ~ name ~ ':user_files'), { 'enabled': False}) -%}
#set homedir based on the username
{%- set home = user.get('home', "/home/%s" %name) -%}
{%- set user_group = name -%}

#Add user on the defined grups
{% for group in user.get('groups', []) %}
users_{{name}}_{{groups}}_group:
  group:
    - name: {{group}}
    - present
{% endfor %}

users_{{name}}_user:
  group.present:
    - name: {{user_group}}
    - gid: {{ user['uid']}}
  user.present:
    - name: {{ name }}
    - home: {{ home }}
    - shell: {{ user.get('shell') }}
    - uid: {{ user['uid'] }}
    - password: '{{ user['password'] }}'
    - fullname: {{ user['fullname'] }}
    groups:
      - {{ user_group }}
      {% for group in user.get('groups', []) %}
      - {{ group }}
      {% endfor %}

{% endfor %}
