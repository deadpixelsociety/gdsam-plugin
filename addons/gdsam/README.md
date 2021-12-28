# gdsam-plugin
Godot Plugin for SAM (Software Automatic Mouth)

A GDNative library wrapper around the C port of SAM by Sebastian Macke over at https://github.com/s-macke/SAM.

Usage:
* Add the ```addons/gdsam``` folder to your project.
* Go to ```Project > Project Settings > Plugins``` and Enable the ```GDSAM``` plugin.
* Add a ```GDSAM``` node to your scene.
* Call the ```speak(text)``` function to speak or ```speak2D(text, position)``` to speak positionally.
* Call ```interrupt()``` to interrupt any queued phrases.
* Play with the ```speed```, ```pitch```, ```mouth``` and ```throat``` settings to modify the voice. Experiment!
* Some stock voices are included based on the original demo.
  * ```set_voice_default()```
  * ```set_voice_elf()```
  * ```set_voice_old_lady()```
  * ```set_voice_alien()```
  * ```set_voice_stuffy()```
