@tool
extends Node
class_name GDSAM

signal finished_speaking()
signal synthesis_failed(phrase: String, message: String)
signal started_phrase(phrase)
signal finished_phrase(phrase)

# Target phrase length for playback callbacks; native synthesis checks its own capacities.
const MAX_CHARS = 90

@export_range(0, 255) var speed: int = 72:
	set(value):
		speed = clampi(value, 0, 255)
@export_range(0, 255) var pitch: int = 64:
	set(value):
		pitch = clampi(value, 0, 255)
@export_range(0, 255) var mouth: int = 128:
	set(value):
		mouth = clampi(value, 0, 255)
@export_range(0, 255) var throat: int = 128:
	set(value):
		throat = clampi(value, 0, 255)
@export var singing: bool = false
@export var phonetic: bool = false

var _audio_stream_callback: Callable
var _current_player
var _interrupt: bool = false
var _queue: Array[String] = []
var _sample: AudioStreamWAV
var _synth: GDSAMSynth = GDSAMSynth.new()


func _ready() -> void:
	_sample = AudioStreamWAV.new()
	_sample.mix_rate = 22050
	_sample.format = AudioStreamWAV.FORMAT_8_BITS


# Generates synthesized speech from the provided input and plays it with the specified audio player.
# - audio_stream_player: An AudioStreamPlayer or AudioStreamPlayer2D used to play the sample.
# - input: The text to speak.
func speak(audio_stream_player, input: String) -> void:
	_current_player = audio_stream_player
	_interrupt = false
	_configure_sam()
	_enqueue_phrases(input)
	_process_queue()


# Determines if any speech is currently playing.
func is_playing() -> bool:
	if not _current_player:
		return false
	return _current_player.playing


# Interrupts the currently playing speech, if any. No further phrases will be played and 
# the finished_speaking signal will be emitted.
func interrupt() -> void:
	_interrupt = true
	stop()


# Stops the currently playing speech, if any. This does not interrupt and the next phrase will 
# still play if it is available.
func stop() -> void:
	if not _current_player:
		return
	_current_player.stop()


# Sets the audio stream callback function. If provided your function will be passed the audio 
# buffer as a PackedByteArray and you will be expected to return a valid AudioStreamWAV to play. 
# This function allows you to manipulate the stream before it is played.
#
# The mix rate should be 22050.
# The format should be FORAMT_8_BITS.
#
# Example callback function that simply returns the provided buffer:
# func my_callback(buffer: PackedByteArray) -> AudioStreamWAV:
# 	var stream = AudioStreamWAV.new()
#	stream.data = buffer
#	return stream
func set_audio_stream_callback(callback: Callable) -> void:
	_audio_stream_callback = callback


# Sets the default SAM voice.
func set_voice_default() -> void:
	speed = 72
	pitch = 64
	mouth = 128
	throat = 128


# Sets the 'elf' voice type.
func set_voice_elf() -> void:
	speed = 72
	pitch = 64
	mouth = 110
	throat = 160


# Sets the 'alien' voice type.
func set_voice_alien() -> void:
	speed = 42
	pitch = 60
	mouth = 190
	throat = 190


# Sets the 'stuffy' voice type.
func set_voice_stuffy() -> void:
	speed = 82
	pitch = 72
	throat = 105
	mouth = 110


# Sets the 'old lady' voice type.
func set_voice_old_lady() -> void:
	speed = 72
	pitch = 32
	mouth = 145
	throat = 145


func _enqueue_phrases(input: String) -> void:
	_queue.clear()
	_create_phrases(input)


# Two-character SAM tokens. Stress digits belong to the preceding token.
const PHONEME_PAIRS = ["IY", "IH", "EH", "AE", "AA", "AH", "AO", "UH", "AX", "IX", "ER",
	"UX", "OH", "RX", "LX", "WX", "YX", "WH", "NX", "DX", "SH", "TH", "/H", "/X",
	"ZH", "DH", "CH", "EY", "AY", "OY", "AW", "OW", "UW", "GX", "KX", "UL", "UM", "UN"]


func _create_phrases(input: String) -> void:
	var offset = 0
	while offset < input.length():
		var end = mini(offset + MAX_CHARS, input.length())
		if phonetic:
			var cursor = offset
			var token_end = offset
			while cursor < input.length():
				var width = 2 if input.substr(cursor, 2).to_upper() in PHONEME_PAIRS else 1
				var next = cursor + width
				while next < input.length() and input[next] in "12345678":
					next += 1
				if next > end and token_end > offset:
					break
				token_end = next
				cursor = next
				if cursor >= end:
					break
			end = token_end
		if end < input.length():
			var space = input.substr(offset, end - offset).rfind(" ")
			if space > 0:
				_queue.append(input.substr(offset, space))
				offset += space + 1
				continue
		_queue.append(input.substr(offset, end - offset))
		offset = end


func _configure_sam() -> void:
	_synth.set_speed(speed)
	_synth.set_pitch(pitch)
	_synth.set_mouth(mouth)
	_synth.set_throat(throat)
	_synth.set_singing(singing)
	_synth.set_phonetic(phonetic)


func _process_queue() -> void:
	var phrase: String
	var buffer: PackedByteArray
	while true:
		if _interrupt or _queue.size() == 0:
			finished_speaking.emit()
			return
		phrase = _queue.pop_front()
		if phrase.strip_edges().is_empty():
			continue
		buffer = _synth.speak(phrase)
		var message = _synth.get_last_error()
		if not message.is_empty():
			_queue.clear()
			synthesis_failed.emit(phrase, message)
			finished_speaking.emit()
			return
		if not buffer.is_empty():
			break
	if is_playing():
		stop()
	var stream: AudioStreamWAV
	if _audio_stream_callback:
		stream = await _audio_stream_callback.call(buffer)
	else:
		_sample.data = buffer
		stream = _sample
	_current_player.stream = stream
	_current_player.play()
	started_phrase.emit(phrase)
	await _current_player.finished
	finished_phrase.emit(phrase)
	_process_queue()
