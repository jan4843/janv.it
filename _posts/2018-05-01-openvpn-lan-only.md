---
title: Route only local IPs with OpenVPN
---

At home I’ve a Raspberry Pi set up with OpenVPN to access my devices at home without exposing them directly to the internet with port forwarding.

One annoyance is that when I activate my VPN client on my iPhone or a Mac outside home, all my internet traffic goes through my home network before reaching my device making it unnecessarily slower.  
Luckily there is an option in OpenVPN to only route traffic directed to a specific IP, which can be your LAN, `192.168.1.0/24` for example.  
In your `.ovpn` client file, simply add the two lines at the top, after `client`:

```
client
route-nopull
route 192.168.1.0 255.255.255.0
...
```

Of course in the `route` option you have to specify your network and its mask.

One important thing to note is that connecting from a network that happen to also be on `192.168.1.0/24` won’t let you reach your LAN because it would get prioritized. This could be a problem when connecting from other home networks or shops’ Wi-Fi, but usually not from cellular networks or corporate/academic networks.  
If you think this might affect you, then consider moving your LAN to something more unique like `192.168.146.0/24` or `10.0.87.0/24`.

If the solution doesn’t work for you it could be that your OpenVPN server configuration doesn’t allow traffic to local hosts or your firewall blocks it. In my setup I use [Angristan’s OpenVPN-install script](https://github.com/Angristan/OpenVPN-install), which works on Debian, Ubuntu, CentOS and Arch Linux.
