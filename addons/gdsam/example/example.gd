extends Control

@onready var gdsam: GDSAM = $GDSAM
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var speed_label: Label = %SpeedLabel
@onready var speed: HSlider = %Speed
@onready var pitch_label: Label = %PitchLabel
@onready var pitch: HSlider = %Pitch
@onready var mouth_label: Label = %MouthLabel
@onready var mouth: HSlider = %Mouth
@onready var throat_label: Label = %ThroatLabel
@onready var throat: HSlider = %Throat
@onready var singing_label: Label = %SingingLabel
@onready var singing: CheckBox = %Singing
@onready var phonetic_label: Label = %PhoneticLabel
@onready var phonetic: CheckBox = %Phonetic
@onready var voice_label: Label = %VoiceLabel
@onready var voice: OptionButton = %Voice
@onready var input: LineEdit = %Input


func _ready() -> void:
	gdsam.set_audio_stream_callback(my_callback)
	set_voice()


func my_callback(buffer: PackedByteArray) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.data = buffer
	return stream


func set_voice() -> void:
	if not gdsam:
		return
	match voice.get_selected_id():
		0:
			gdsam.set_voice_default()
		1:
			gdsam.set_voice_elf()
		2:
			gdsam.set_voice_alien()
		3:
			gdsam.set_voice_stuffy()
		4:
			gdsam.set_voice_old_lady()
	set_labels()
	set_sliders()


func set_labels() -> void:
	speed_label.text = "Speed (%d)" % gdsam.speed
	pitch_label.text = "Pitch (%d)" % gdsam.pitch
	mouth_label.text = "Mouth (%d)" % gdsam.mouth
	throat_label.text = "Throat (%d)" % gdsam.throat


func set_sliders() -> void:
	speed.value = gdsam.speed
	pitch.value = gdsam.pitch
	mouth.value = gdsam.mouth
	throat.value = gdsam.throat


func _on_speed_value_changed(value: float) -> void:
	gdsam.speed = speed.value
	set_labels()


func _on_pitch_value_changed(value: float) -> void:
	gdsam.pitch = pitch.value
	set_labels()


func _on_mouth_value_changed(value: float) -> void:
	gdsam.mouth = mouth.value
	set_labels()


func _on_throat_value_changed(value: float) -> void:
	gdsam.throat = throat.value
	set_labels()


func _on_singing_toggled(button_pressed: bool) -> void:
	gdsam.singing = button_pressed


func _on_phonetic_toggled(button_pressed: bool) -> void:
	gdsam.phonetic = button_pressed


func _on_voice_item_selected(index: int) -> void:
	set_voice()


func _on_speak_pressed() -> void:
	gdsam.speak(audio_stream_player, input.text)


func _on_interrupt_pressed() -> void:
	gdsam.interrupt()
