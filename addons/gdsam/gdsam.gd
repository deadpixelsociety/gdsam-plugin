tool
extends Node

signal loaded_buffer(buffer, callback)
signal finished_speaking()
signal finished_phrase()

class BufferCallback:
	var audio_stream_override: AudioStream = null

const DEFAULT_SPEED = 72
const DEFAULT_PITCH = 64
const DEFAULT_MOUTH = 128
const DEFAULT_THROAT = 128
const DEFAULT_VOLUME = 1.0
const DEFAULT_SINGING = false
const DEFAULT_PHONETIC = false
const DEFAULT_AUDIO_BUS = "Master"
const MAX_CHARS = 90

export(int, 0, 255) var speed = DEFAULT_SPEED
export(int, 0, 255) var pitch = DEFAULT_PITCH
export(int, 0, 255) var mouth = DEFAULT_MOUTH
export(int, 0, 255) var throat = DEFAULT_THROAT
export(bool) var singing = DEFAULT_SINGING
export(bool) var phonetic = DEFAULT_PHONETIC
export(float, 0, 1) var volume = DEFAULT_VOLUME
export(String) var audio_bus = DEFAULT_AUDIO_BUS

var _current_player
var _interrupt = false
var _player
var _player2D
var _sample: AudioStreamSample
var _queue = []

onready var _gdsam = preload("res://addons/gdsam/bin/gdsam.gdns").new()


func _ready():
	_player = AudioStreamPlayer.new()
	_player2D = AudioStreamPlayer2D.new()
	_sample = AudioStreamSample.new()
	_sample.mix_rate = 22050
	_sample.format = AudioStreamSample.FORMAT_8_BITS
	add_child(_player)
	add_child(_player2D)


func speak(input: String, positional: bool = false):
	_interrupt = false
	_configure_sam()
	_current_player = _player if not positional else _player2D
	_configure_player(_current_player)
	_enqueue_phrases(input)
	_process_queue()


func speak2D(input: String, position: Vector2):
	_player2D.position = position
	speak(input, true)


func interrupt():
	_interrupt = true
	if _current_player:
		_current_player.stop()


func stop():
	if _player.playing:
		_player.stop()
	if _player2D.playing:
		_player2D.stop()


func get_player() -> AudioStreamPlayer:
	return _player as AudioStreamPlayer


func get_player2D() -> AudioStreamPlayer2D:
	return _player2D as AudioStreamPlayer2D


func set_voice_default():
	speed = DEFAULT_SPEED
	pitch = DEFAULT_PITCH
	mouth = DEFAULT_MOUTH
	throat = DEFAULT_THROAT
	singing = DEFAULT_SINGING
	phonetic = DEFAULT_PHONETIC


func set_voice_elf():
	speed = 72
	pitch = 64
	mouth = 110
	throat = 160


func set_voice_alien():
	speed = 42
	pitch = 60
	mouth = 190
	throat = 190


func set_voice_stuffy():
	speed = 82
	pitch = 72
	throat = 105
	mouth = 110


func set_voice_old_lady():
	speed = 72
	pitch = 32
	mouth = 145
	throat = 145


func _enqueue_phrases(input: String):
	_queue.clear()
	_create_phrases(input)


func _create_phrases(input: String):
	if input.length() <= MAX_CHARS:
		_queue.append(input)
		return
	var phrase = input.substr(0, MAX_CHARS)
	var i = phrase.length() - 1
	while phrase[i] != ' ' and i >= 0:
		i -= 1
	if i <= 0:
		_queue.append(phrase)
		_create_phrases(input.substr(MAX_CHARS + 1))
	else:
		_queue.append(phrase.substr(0, i))
		_create_phrases(input.substr(i + 1))


func _configure_sam():
	_gdsam.set_speed(speed)
	_gdsam.set_pitch(pitch)
	_gdsam.set_mouth(mouth)
	_gdsam.set_throat(throat)
	_gdsam.set_singing(singing)
	_gdsam.set_phonetic(phonetic)


func _configure_player(player):
	player.bus = audio_bus
	player.volume_db = linear2db(volume)


func _process_queue():
	if _interrupt or _queue.size() == 0:
		emit_signal("finished_speaking")
		return
	var phrase = _queue.pop_front()
	var buffer = _gdsam.speak(phrase) as PoolByteArray
	if not buffer:
		return
	var callback = BufferCallback.new()
	emit_signal("loaded_buffer", buffer, callback)
	if _current_player.playing:
		_current_player.stop()
	if not callback.audio_stream_override:
		_sample.data = buffer
		_current_player.stream = _sample
	else:
		_current_player.stream = callback.audio_stream_override
	_current_player.play()
	yield(_current_player, "finished")
	emit_signal("finished_phrase")
	_process_queue()
