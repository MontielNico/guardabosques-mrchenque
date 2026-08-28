extends Node

# SoundManager - Generador procedural de efectos de sonido en GDScript
# No requiere archivos de audio externos, crea los samples directamente en memoria.

var sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func _get_available_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]

func play_sound(sound_type: String) -> void:
	var stream = _generate_sound(sound_type)
	if stream:
		var player = _get_available_player()
		player.stream = stream
		player.volume_db = -4.0
		player.play()

func _generate_sound(type: String) -> AudioStreamWAV:
	var sample_rate = 22050
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	
	var data = PackedByteArray()
	var duration = 0.2
	
	match type:
		"stamp_approve": # Golpe seco metálico / madera con tono agudo positivo
			duration = 0.22
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 22.0)
				var impact = sin(2.0 * PI * (90.0 - t * 150.0) * t)
				var ping = sin(2.0 * PI * 520.0 * t) * 0.4
				var noise = (randf() * 2.0 - 1.0) * exp(-t * 40.0) * 0.5
				var val = clampf((impact * 0.6 + ping + noise) * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))
				
		"stamp_reject": # Golpe seco más grave y pesado
			duration = 0.28
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 16.0)
				var impact = sin(2.0 * PI * (65.0 - t * 80.0) * t)
				var thud = sin(2.0 * PI * 130.0 * t) * 0.5
				var noise = (randf() * 2.0 - 1.0) * exp(-t * 25.0) * 0.6
				var val = clampf((impact * 0.7 + thud + noise) * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"paper": # Ruido de papel / hojeo
			duration = 0.12
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = sin((float(i) / total_samples) * PI)
				var noise = (randf() * 2.0 - 1.0) * 0.7
				var val = clampf(noise * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"click": # Click de interfaz
			duration = 0.04
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 90.0)
				var beep = sin(2.0 * PI * 1200.0 * t)
				var val = clampf(beep * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"radio": # Chirp de walkie-talkie
			duration = 0.35
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var freq = 880.0 if t < 0.08 else (1760.0 if t < 0.16 else 600.0)
				var tone = sin(2.0 * PI * freq * t) * 0.5
				var static_noise = (randf() * 2.0 - 1.0) * 0.35
				var env = 1.0 if t < 0.3 else (0.35 - t) / 0.05
				var val = clampf((tone + static_noise) * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"car_engine": # Motor de auto llegando
			duration = 0.5
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = sin((float(i) / total_samples) * PI)
				var motor = sin(2.0 * PI * 45.0 * t) * 0.6 + sin(2.0 * PI * 90.0 * t) * 0.3
				var noise = (randf() * 2.0 - 1.0) * 0.2
				var val = clampf((motor + noise) * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"coin": # Sonido de moneda / dinero
			duration = 0.25
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 12.0)
				var bell = sin(2.0 * PI * 987.77 * t) * 0.6 + sin(2.0 * PI * 1318.5 * t) * 0.4
				var val = clampf(bell * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		"alarm": # Alarma de emergencia
			duration = 0.4
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var freq = 440.0 + sin(2.0 * PI * 8.0 * t) * 200.0
				var env = 0.8
				var val = clampf(sin(2.0 * PI * freq * t) * env, -1.0, 1.0)
				data.append(int((val + 1.0) * 127.5))

		_: # Sonido genérico
			duration = 0.08
			var total_samples = int(sample_rate * duration)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var val = sin(2.0 * PI * 440.0 * t) * exp(-t * 20.0)
				data.append(int((val + 1.0) * 127.5))

	wav.data = data
	return wav
