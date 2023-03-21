---
layout: default
permalink: /
social:
  - name: GitHub
    url: https://github.com/jan4843
  - name: Pinboard
    url: https://pinboard.in/u:jan4843
  - name: Instagram
    url: https://instagram.com/jan4843
  - name: Telegram
    url: https://t.me/jan4843
---

I am a graduate software engineer from Italy living in Austria. My interests include backend development, Linux containers, automation on Apple platforms. I care about developer experience and minimalism in software.

<ul class="menu">
{% for social in page.social %}
	<li>
		<a href="{{ social.url }}">
			{% include icons/{{ social.name | slugify }}.svg %}
			<span>{{ social.name }}</span>
		</a>
	</li>
{% endfor %}
</ul>

Email me at <{{ site.author.email }}>.
