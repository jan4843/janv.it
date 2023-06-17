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
---

# Jan Vitturi

I am a graduate software engineer from Italy living in Austria. My interests include backend development, Linux containers, automation on Apple platforms. I care about developer experience and minimalism in software.

## Contacts

{% for contact in page.contacts -%}
- [{{ contact.name }}]({{ contact.url }})
{% endfor %}

## Blog

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url }})  
{{ post.date | date: '%Y-%m-%d' }}
{% endfor %}
