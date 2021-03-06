{% from "bit_base_minions/map.jinja" import config with context %}
{%- set settings = config.settings  %}
{%- set minion_host = config.minion_hosts.get(grains.id, false) %}
{%- set default_hostname = grains.id.replace('.', '-').split('-')[:-2] %}

{%- if minion_host.net_adapter is defined and minion_host.net_adapter|length %}
install_net_adapter_{{ grains.server_id }}:
  cmd.run:
  - name: New-NetIPAddress –IPAddress {{ minion_host.ip_addrs | default('') | join('') }} -DefaultGateway {{ settings.gateway }} -PrefixLength 24 -InterfaceIndex (Get-NetAdapter -Name {{ minion_host.net_adapter | default('Ethernet') }}).InterfaceIndex
  - shell: powershell
  - unless:
    - Get-NetIPAddress -IPAddress {{ minion_host.ip_addrs | default('') | join('') }}

# https://github.com/saltstack/salt/issues/58361
#install_net_adapter_{{ grains.server_id }}:
#  network.managed:
#    - name: '{{ minion_host.net_adapter }}'
#    - dns_proto: {{ settings.dns_proto | default('dhcp' ) }}
#    {%- if settings.dns_servers is defined and settings.dns_servers|length %}
#    - dns_servers: {{ settings.dns_servers }}
#    {%- endif %}
#    {%- if settings.gateway is defined and settings.gateway|length %}
#    - gateway: {{ settings.gateway }}
#    {%- endif %}
#    - ip_proto: {{ minion_host.ip_proto | default('dhcp' ) }}
#    - ip_addrs: {{ minion_host.ip_addrs | default('') }}

install_dns_{{ grains.server_id }}:
  cmd.run:
  - name: Set-DNSClientServerAddress –InterfaceIndex (Get-NetAdapter).InterfaceIndex –ServerAddresses {{ settings.dns_servers | join(',') }}
  - shell: powershell

set_hostname:
  system.hostname:
    - name: {{ minion_host.hostname | default(default_hostname) }}
{%- endif %}
