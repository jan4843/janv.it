var lang = navigator.language || navigator.languages[0];
var timeTags = document.getElementsByTagName('time');

for (var i = 0; i < timeTags.length; i++) {
	var options = {};
	switch (timeTags[i].getAttribute('date-style')) {
		case 'full':
			options.weekday = 'long';
		case 'long':
			options.year = 'numeric';
			options.month = 'long';
			options.day = 'numeric';
			break;

		case 'medium':
			options.year = 'numeric';
			options.month = 'short';
			options.day = 'numeric';
			break;

		case 'short':
			options.year = '2-digit';
			options.month = 'numeric';
			options.day = 'numeric';
			break;

		default:
			continue;
	}

	var date = new Date(timeTags[i].getAttribute('datetime').split('T')[0]);
	timeTags[i].innerHTML = date.toLocaleDateString(lang, options);
}
