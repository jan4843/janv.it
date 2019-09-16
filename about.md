---
layout: default
permalink: /
social:
  - name: Pinboard
    url: https://pinboard.in/u:jan4843
  - name: Twitter
    url: https://twitter.com/jan4843
  - name: GitHub
    url: https://github.com/jan4843
  - name: Instagram
    url: https://instagram.com/jan4843
  - name: Telegram
    url: https://t.me/jan4843
---

I am an Italian Software Engineering student currently living in Austria. My interests include back end web development and personal productivity. I care about semantic, user experience, accessibility and performance.

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
