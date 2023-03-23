# Deferred to-dos in Things

After a long time with OmniFocus I am trying Things 3 again. I do enjoy the design, like anyone using the app would, but a few things are missing for me: defer dates and sequential projects.

To clarify what’s the difference between a *start date* and a *defer date*, for me, at least: the start date is the date a task if flagged for the day, the defer date is the date when a task just becomes available.  
In OmniFocus, if a task is flagged, then its defer date is actually a start date for me.

Defer dates are important for me because I schedule school homework in advance. Every week I have to turn in an assignment, and then a get a new one. Since I can only start working on an assignment only after I receive it, its relative task has to have a defer date and a due date. Then I can choose whenever I want during the week when I want to work on the assignment. I don’t want it to get shown in the Today view as soon as it’s available.  
Unfortunately that is not possible with Things, so I had to work around that.

I wrote an AppleScript that looks for today’s tasks that are tagged with “Deferred”, removes the tag and removes the start date by moving the tasks to the “Anytime” list. I set the script to run at 00:01 every day with Keyboard Maestro.

```applescript
set deferredTagName to "Deferred"

to replaceText(someText, oldItem, newItem)
	set {tempTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, oldItem}
	set {itemList, AppleScript's text item delimiters} to {text items of someText, newItem}
	set {someText, AppleScript's text item delimiters} to {itemList as text, tempTID}
	return someText
end replaceText

tell application "Things3"
	set todayToDos to to dos of list "Today"
	repeat with toDo in todayToDos
		if deferredTagName is in tag names of toDo then
			set tagNames to tag names of toDo
			set newTagNames to my replaceText(tagNames, deferredTagName, "")
			set tag names of toDo to newTagNames
			move toDo to list "Anytime"
		end if
	end repeat
end tell
```

Now if I want a task to be deferred – not start – on a certain day, I would schedule the task and set a “Deferred” tag to it. When the defer date comes, the script would remove the task’s date and the task is available in the “Anytime” list, and is no longer hidden.
