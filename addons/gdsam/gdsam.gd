tool
extends Node

signal finished_speaking()

const DEFAULT_SPEED = 72
const DEFAULT_PITCH = 64
const DEFAULT_MOUTH = 128
const DEFAULT_THROAT = 128
const DEFAULT_VOLUME = 1.0
const DEFAULT_SINGING = false
const DEFAULT_PHONETIC = false
const DEFAULT_AUDIO_BUS = "Master"

export(int, 0, 255) var speed = DEFAULT_SPEED
export(int, 0, 255) var pitch = DEFAULT_PITCH
export(int, 0, 255) var mouth = DEFAULT_MOUTH
export(int, 0, 255) var throat = DEFAULT_THROAT
export(bool) var singing = DEFAULT_SINGING
export(bool) var phonetic = DEFAULT_PHONETIC
export(float, 0, 1) var volume = DEFAULT_VOLUME
export(String) var audio_bus = DEFAULT_AUDIO_BUS

var _player
var _player2D

onready var _gdsam = preload("res://addons/gdsam/bin/gdsam.gdns").new()


func _ready():
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player2D = AudioStreamPlayer2D.new()
	add_child(_player2D)


func speak(input: String, positional: bool = false):
	_configure_sam()
	var player = _player if not positional else _player2D
	_configure_player(player)
	var buffer = _gdsam.speak(input) as PoolByteArray
	if not buffer:
		return
	if player.playing:
		player.stop()
	player.stream = _create_sample(buffer)
	player.play()
	yield(player, "finished")
	emit_signal("finished_speaking")


func speak2D(input: String, position: Vector2):
	_player2D.position = position
	speak(input, true)


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


func _create_sample(buffer: PoolByteArray) -> AudioStreamSample:
	var sample = AudioStreamSample.new()
	sample.mix_rate = 22050
	sample.format = AudioStreamSample.FORMAT_8_BITS
	sample.data = buffer
	return sample


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
