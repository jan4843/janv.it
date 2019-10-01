---
title: Disable Shortcuts automations notifications
---

iOS 13.1 brought automations to Shortcuts but one thing changed from the early betas of iOS 13: it is no longer possible to disable notifications for the Shortcuts app from Settings. This means every time an automation with ‘Ask Before Running’ disabled is triggered, it will show a confirmation notification that then stays in the Notification Center.

![Screenshot of a Shortcuts notification](/media/shortcuts-notification.png)

It is, however, possible to force iOS not to display notifications from Shortcuts thanks to a crafted configuration profile. The profile can be created with [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344) and only has a notification setting with ‘Allow Notifications’ disabled for Shortcuts. The bundle identifier `com.apple.shortcuts` must be manually specified otherwise the search feature will find the old Shortcuts app for iOS 12 which has a different bundle identifier.

![Notification Settings for Shortcuts in Apple Configurator 2](/media/notification-settings-shortcuts.png)

Alternatively you can [download the profile](/downloads/disable-shortcuts-notifications.mobileconfig) I created.

**The caveat is that in order to install the profile on an iOS device, the device must be [supervised](https://support.apple.com/en-us/HT202837). Supervisioning doesn’t have any requirements and can be done with [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344) for macOS, however the device must be initialized.**

Note that also automations that require user confirmation such as time-based or location-based automations will not show any notification and become therefore ineffective.
