 ## MultiSound Changer for MacOS
 Latest release https://github.com/rlxone/MultiSoundChanger/releases
 
 A small tool for changing sound volume **even for aggregate devices** cause native sound volume controller can't change volume of aggregate devices (it was always pain in the ass with my laptop).
 


Features:
* **Changing sound volume of every device** (even virtual aggregate device volume by changing volume of every device in aggregate device)
* Changing default output device
* Native appearance (looks like native volume controller)

I think it can be very useful if you're using VoodooHDA with 4.0+ sound on the board (my use case), but you can find another use cases.

## Usage

For example if you want to play 2 or more output devices at the same time you should:
* Create aggregate device in Audio MIDI Setup
* Add all output devices you want to this new aggregate device
* Hide default sound controller icon if enabled (by dragging away or in audio preferences)
* Use our app to control sound volume
* Add our app to startup (if you need)

![GitHub Logo](https://pp.userapi.com/c636819/v636819907/55c8e/QeAz-PwXh24.jpg)


## Inspiration
* [retrography/audioswitch](https://github.com/retrography/audioswitch)

## Licence
* This project is released under the Apache 2.0 licence. See LICENCE
