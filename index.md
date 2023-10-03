---
contacts:
  - name: GitHub
    url: https://github.com/jan4843
  - name: Pinboard
    url: https://pinboard.in/u:jan4843
  - name: Instagram
    url: https://instagram.com/jan4843
  - name: Telegram
    url: https://t.me/jan4843
  - name: Email
    url: mailto:vitturi.jan@gmail.com

projects:
  - name: dotfiles
    tags: [Shell]
    url: https://github.com/jan4843/dotfiles
    description: |
      Running configuration of my hosts as a bare Git repository for the home directory.
  - name: setup
    tags: [macOS, Shell, Homebrew]
    url: https://github.com/jan4843/setup
    description: |
      Running configuration for my macOS workstations, to bootstrap and reconcile applications and settings.
  - name: infrastructure
    tags: [Ansible, Grafana]
    url: https://github.com/jan4843/infrastructure
    description: |
      Ansible playbooks and Grafana dashboards to provision and monitor my servers running self-hosted services.
  - name: docker_stats_exporter
    tags: [Go]
    url: https://github.com/jan4843/docker_stats_exporter
    description: |
      Prometheus exporter for containers resources usage provided by the Docker Engine.
  - name: xarpd
    tags: [Go]
    url: https://github.com/jan4843/xarpd
    description: |
      ARP daemon that helps merging multiple networks with overlapping subnets.
  - name: ctrace
    date: 2022
    tags: [eBPF, Python]
    url: https://github.com/jan4843/ctrace
    description: |
      Tracer for system calls and Linux capabilities checks for the Docker Engine for generating security profiles.
---

# Jan Vitturi

I am a graduate software engineer from Italy living in Austria. My interests include backend development, Linux containers, automation on Apple platforms. I care about developer experience and minimalism in software.

## Contacts

{% for contact in page.contacts -%}
- [{{ contact.name }}]({{ contact.url }})
{% endfor %}

## Projects

{% for project in page.projects %}
- [{{ project.name }}]({{ project.url }}) {% if project.date %}({{ project.date }}){% endif %} <small>{{ project.tags | join: ', ' }}</small>  
{{ project.description }}
{% endfor %}

## Blog

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url }})  
{{ post.date | date: '%Y-%m-%d' }}
{% endfor %}
