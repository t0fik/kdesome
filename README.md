# KDEsome

An [awesome](http://awesome.naquadah.org/) theme tailored specifically to be a drop-in replacement for KDE's Plasma Desktop.

Before present a little more about this, let's see how it looks like.

**KDEsome Main Screen**

![KDEsome Main Screen](https://raw.githubusercontent.com/denydias/kdesome/master/screenshots/1-kdesome.png)

**KDEsome Main Menu**

![KDEsome Main Menu](https://raw.githubusercontent.com/denydias/kdesome/master/screenshots/2-kdesome-menu.png)

**KDEsome Widgets**

![KDEsome Widgets](https://raw.githubusercontent.com/denydias/kdesome/master/screenshots/3-kdesome-widgets.png)

**KDEsome Dual Head**

![KDEsome Dual Head](https://raw.githubusercontent.com/denydias/kdesome/master/screenshots/4-kdesome-dualhead.png)

**KDEsome Terminal Tile**

![KDEsome Terminal Tile](https://raw.githubusercontent.com/denydias/kdesome/master/screenshots/5-kdesome-termtile.png)

## Dependencies

To use KDEsome, first make sure that you have meet all dependencies. They are:

1. **awesome:** a highly configurable, next generation framework window manager for X. It is very fast, extensible and licensed under the GNU GPLv2 license. You can [download](http://awesome.naquadah.org/download/) packages for many Linux distributions straight from the project website or use your favorite package manager.

 If you are in Slackware, you can properly install it and its dependencies with (assuming you have `sbopkg` in place):

 ```console
 # sbopkg -i "lua lgi libxdg-basedir awesome"
 ```

2. **[Unclutter](http://unclutter.sourceforge.net/):** a program which runs permanently in the background of an X11 session to hide the mouse cursor when it's not in use (and bring it back when you need it too). Same as above, most distributions have packages for it.

 Slackware users should run this to get Unclutter in place:

 ```console
 # touch /usr/lib64/X11/config/host.def
 # sbopkg -i unclutter
 ```

3. **[XDG-Menu](https://www.archlinux.org/packages/community/any/archlinux-xdg-menu/):** automatic generation for WM menu from xdg files. This is an Arch Linux app. I don't know if it's available to other distros out there.

 Slackware users can install it by following this LQ's [directions](http://www.linuxquestions.org/questions/slackware-14/slackware-xdg-menus-925629/). Just download the provided package and install it with:

  ```console
  # installpkg slackware-xdg-menu-0.7.5.4-1-any-2.txz
  ```

4. **[Compton](https://github.com/chjj/compton):** A compositor for X11. Compton should be available for many distros too.

 At Slackware, install it by running:

 ```console
 # sbopkg -i "libconfig compton"
 ```

Although KDEsome is made to work in cooperation with KDE, it's not required that you have KDE installed to use it. Just keep in mind that KDEsome has some configurations in [rc.lua](https://github.com/denydias/kdesome/blob/master/rc.lua#L75) that demands KDE applications installed, such as Dolphin, Kate, Kontact and Kopete. Whoever it's easy enough so a user change that for anything of the choice.

Now you are ready to go for KDEsome.

## Installation

KDEsome installation is kinda simple. It's just a matter to clone this repository and tell KDE that you don't want Plasma Desktop as your Window Manager anymore. So, let's do it:

```console
$ cd ~/.config
$ git clone --recursive https://github.com/denydias/kdesome awesome
$ echo "export KDEWM=awesome" > ~/.kde/env/set_window_manager.sh
$ chmod +x ~/.kde/env/set_window_manager.sh
```

Now go to **System Settings > Startup and Shutdown > Autostart > uncheck Plasma Workspace** item. Do not remove this item from the list, as KDE will assume the default behavior that is to start Plasma anyway.

Next go to **System Settings > Startup and Shutdown > Service Manager > uncheck Status Notifier Manager** item. This will allow the system tray to show up in KDEsome.

Also under **Service Manager**, you can also stop and disable **Plasma Networkmanagement module** and **Display Management change monitor**. The remaining services can be left alone.

After restart into awesome and you can't see the NetworkManager icon on your system tray, make sure you have the package `network-manager-applet` and its related installed item is enabled in **System Settings > Startup and Shutdown > Autostart**.

If you want to change the `nm-applet` icon to match KDEsome, run in Slackware (adapt for another distro):

```console
# cp code/mine/kdesome/themes/kdesome/trayicons/*.png \
/usr/share/icons/hicolor/16x16/apps/
# rm -f /usr/share/icons/icon-theme.cache && \
/usr/bin/gtk-update-icon-cache -t -f /usr/share/icons/
```

Restart you KDE and you should get it done.

## Features

Many! Hit `Mod4+F1` to get a nice help screen for KDEsome (it's in Brazilian Portuguese, but easy to translate).

The most nice feature is the seamless integration with underlying KDE. You can use many of your KDE applications and global shortcuts without conflicts with awesome. Screenshots (`Printscreen`), session control (`Ctrl+Alt+Del`), KRunner, Yakuake activation and many other shortcuts comes straight from KDE without a glitch.

KDE also takes care of dual head (multiple monitors) setup for you. This feature plays nicely with awesome and compton, so your multiple monitors works just as you expect they do without hassle.

You can even rely on the fantastic KDE Connect to remote control your screen or media player as KDEsome was made to keep all the KDE goodies intact.

## TODO

Here are some TODOs. These are things I don't know how to get it done in Lua and awesome APIs and/or do not had the time to fix yet. If you are willing to help, please open an issue or a pull request.

- [ ] Set different wallpapers for each tag, on each screen.
- [ ] Remove Conky from the taglist so that square on tag 6 do not show up for it (there are a [thread](http://www.mail-archive.com/awesome@naquadah.org/msg07817.html) for this in awesome's mail list, but no solution yet).
- [ ] Adjust windows geometry upon application start (it works fine after a WM restart, but not quite good at application start).
- [ ] Localize help (maybe using `partials` method from this [repo](https://github.com/noah/awesome/tree/master)).
- [X] Match that ugly `nm-applet` icon with their neighbors in the systray.

## Why You Did That?

It's just fair you ask, indeed. There are three main reasons I did KDEsome rather than use one of the tons [ready-made](http://awesome.naquadah.org/wiki/User_Configuration_Files) awesome [themes](https://github.com/copycat-killer/awesome-copycats) out there.

1. **Saving Resources:** I'm a minimalist kind of person. I see beauty in less resources, rather than more. I don't like expensive stuff and I try to be the most productive I can with the minimal set of resources available. This sounds elegant to me.

 As such, I run at very low profile with my technological needs. My actual machine is just a 2nd gen Core i3 running at 1.4GHz top speed. It has a fair 10GB RAM and a 240GB SSD, which after wear & tear protection holds 166GB. This is the system where I make my living. With that specs, I can't and don't want to spend cycles with all that KDE Plasma Desktop bells and whistles, totally unnecessary.

 So, here are some figures got with that machine:

  1. KDE with Plasma Desktop:

    - Startup loading apps: Conky, Yakuake and Synology CloudStation
    - Cold boot time (from power up to Plasma Desktop appears): 33s
    - Memory usage (as soon as the boot finishes): 1.38GB

  2. KDE with awesome:

    - Startup loading apps: Conky, Yakuake and Synology CloudStation
    - Cold boot time (from power up to awesome appears): 23.57s (28.57% faster)
    - Memory usage (as soon as the boot finishes): 523MB (62.10% less)

2. **Productivity:** I work with many complex activities in a typical day. When I'm at it, I don't like to get distracted with things that are not absolutely related to the task I'm working at. Although you can 'silence' Plasma Desktop and many KDE applications as you wish, you need to make this happen by going into various different places that are quite confusing to keep track of. awesome centralizes this in a 'environment as code' approach.

 Another productivity feature of awesome is its tiling approach, where it takes care of windows (clients) placement alone, while you just have to think about the task you're working on. Forget about move and resize windows as this is not important for the duty and wastes time.

3. **Politics:** Although I'm still a huge fan of KDE and its products (Frameworks, Plasma and Applications), I do not like the way the project is being conducted towards pseudo 'open source' dependencies such as systemd, wayland and others. There's still a choice, but nobody can say for sure how long it is going to last. By replacing such an important part of a desktop environment as the window manager with awesome, I'm just a small step away to replace entire KDE if project directions breaks the confidence I have put on them over the years.

## Acknowledgments

I would like to thanks these folks:

- Jerónimo Navavo, which after his [post](https://plus.google.com/113723455617885553999/posts/CXNR7dEjVbU) about awesome and Slackware community at Google+ gave me the sparks to try something different.

- All the awesome [developers](http://awesome.naquadah.org/community/).

- Luke Boham, whose GitHub repositories are state-of-the-art for any awesome enthusiast. KDEsome is entirely based on his awesome [Powerarrow Darker](https://github.com/copycat-killer/awesome-copycats).

## Licenses

My code for KDEsome is licensed under [GNU GENERAL PUBLIC LICENSE Version 3](http://www.gnu.org/licenses/gpl-3.0.txt).

Code of others are licensed under their own terms.
