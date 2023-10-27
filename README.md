# gdsam-plugin
Godot 4+ Plugin for SAM (Software Automatic Mouth)

A GDExtension library wrapper around the C port of SAM by Sebastian Macke over at https://github.com/s-macke/SAM.

The Godot 3.5 version of this plugin is still available on the [3.5 branch](https://github.com/deadpixelsociety/gdsam-plugin/tree/3.5).

**NOTICE: There are breaking changes from the 3.5 version of this plugin. Please see the usage below and the example scene provided.**

Usage:
* Add the ```addons/gdsam``` folder to your project.
* Go to ```Project > Project Settings > Plugins``` and Enable the ```GDSAM``` plugin.
* Add a ```GDSAM``` node to your scene.
* Call the ```speak(audio_stream_player, text)``` function to speak using your provided ```AudioStreamPlayer``` or ```AudioStreamPlayer2D```.
* Call ```interrupt()``` to interrupt any queued phrases.
* (Optionally) Provide your own callback to ```set_audio_stream_callback(callback)``` to grab the buffered speech data and provide your own audio stream before it is played.
* Play with the ```speed```, ```pitch```, ```mouth``` and ```throat``` settings to modify the voice. Experiment!
* GDSAM can speak plain text when ```phonetic``` is false, or it can be enabled and you can provide your own phonemes. See the [original documentation](https://archive.org/details/user_manual_s.a.m./page/n15/mode/2up) for some examples.
* Some stock voices are included based on the original demo.
  * ```set_voice_default()```
  * ```set_voice_elf()```
  * ```set_voice_old_lady()```
  * ```set_voice_alien()```
  * ```set_voice_stuffy()```
