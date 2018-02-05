---
title: Schedule Time Machine to Mount Your HDD When Necessary
description: Keep your spinning hard drive quiet when you don’t need it
---

I love the simplicity of Time Machine but I also hate having a loud hard drive constantly spinning. What I would hate even more is plugging and unplugging the USB every time I want to backup my Mac. (And you never *want* to backup your stuff, you just want it to happen automatically.)  

So I came up with a few scripts that keep the HDD unmounted, and only mount it once a day to perform a backup. Technically it’s just the HDD partition that gets unmounted (or you wouldn’t be able to mount it again programatically), but that keeps it always quiet anyway.

At login, after the HDD gets mounted automatically, this script unmounts it:
```shell
while ! diskutil info 9821D40D-2812-9843-3448-2712B2E19327; do
	sleep 1
done
diskutil unmount 9821D40D-2812-9843-3448-2712B2E19327
```

The UUID you see is the ‘Volume UUID’ of the partition you can obtain via Disk Utility knowing the volume name (the one you see in Finder sidebar, “Backup” in my case):
```shell
$ diskutil info "Backup" | grep "Volume UUID"
   Volume UUID:              9821D40D-2812-9843-3448-2712B2E19327
```

At night when I’m sleeping this script mounts the HDD, triggers a Time Machine backup and wait it to finish to then unmount the HDD immediatly:
```shell
diskutil mount 9821D40D-2812-9843-3448-2712B2E19327
tmutil startbackup --auto --block
diskutil unmount 9821D40D-2812-9843-3448-2712B2E19327
```

I am doing this with two Keyboard Maestro macros ([one that triggers at login]({{ site.baseurl }}/media/kmmacro-unmount-hdd.png) and [the other at 4 AM every day]({{ site.baseurl }}/media/kmmacro-back-up-with-time-machine.png)), but you can easily do it with [Launch Agents](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html).
