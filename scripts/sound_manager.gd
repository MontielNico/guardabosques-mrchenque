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

func play_sound(sound_type: String, volume_db: float = -32.0) -> void:
	var stream = _generate_sound(sound_type)
	if stream:
		var player = _get_available_player()
		player.stream = stream
		player.volume_db = volume_db
		player.play()

func _generate_sound(type: String) -> AudioStreamWAV:
	var sample_rate = 44100
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	
	var duration = 0.1
	var data = PackedByteArray()
	
	match type:
		"typewriter_key": # Golpe mecánico de tecla nítido y satisfactorio
			duration = 1.2
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			var base_freq = 240.0 + randf() * 40.0
			var click_freq = 2800.0 + randf() * 600.0
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env_click = exp(-t * 260.0)
				var env_body = exp(-t * 90.0)
				var click = sin(2.0 * PI * click_freq * t) * 0.3 * env_click
				var noise = (randf() * 2.0 - 1.0) * 0.2 * env_click
				var body = sin(2.0 * PI * base_freq * t) * 0.45 * env_body
				var val = clampf(click + noise + body, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"typewriter_return": # Retorno de carro mecánico con sutil campanilla/latch
			duration = 0.18
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				# Golpe mecánico inicial
				var env_thud = exp(-t * 55.0)
				var thud = sin(2.0 * PI * 130.0 * t) * 0.45 * env_thud
				var noise_snap = (randf() * 2.0 - 1.0) * 0.25 * exp(-t * 180.0)
				
				# Campanilla metálica clásica de fin de línea / retorno
				var env_bell = exp(-t * 22.0)
				var bell = (sin(2.0 * PI * 1760.0 * t) * 0.22 + sin(2.0 * PI * 2640.0 * t) * 0.12) * env_bell
				
				var val = clampf(thud + noise_snap + bell, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"stamp_approve": # Sello de aprobación limpio y firme
			duration = 0.22
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 24.0)
				var impact = sin(2.0 * PI * (120.0 - t * 180.0) * t) * 0.5
				var ping = sin(2.0 * PI * 680.0 * t) * 0.25
				var noise = (randf() * 2.0 - 1.0) * exp(-t * 60.0) * 0.25
				var val = clampf((impact + ping + noise) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"stamp_reject": # Golpe seco grave y contundente
			duration = 0.25
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 18.0)
				var impact = sin(2.0 * PI * (75.0 - t * 70.0) * t) * 0.65
				var thud = sin(2.0 * PI * 110.0 * t) * 0.3
				var noise = (randf() * 2.0 - 1.0) * exp(-t * 35.0) * 0.2
				var val = clampf((impact + thud + noise) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"paper": # Hojeo suave y nítido de papel
			duration = 0.12
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = sin((float(i) / float(total_samples)) * PI)
				var noise = (randf() * 2.0 - 1.0) * 0.45
				var val = clampf(noise * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"click": # Click de interfaz limpio
			duration = 0.03
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 110.0)
				var beep = sin(2.0 * PI * 1400.0 * t) * 0.5
				var click_noise = (randf() * 2.0 - 1.0) * 0.2 * env
				var val = clampf((beep + click_noise) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"radio": # Chirp de radio transmisor
			duration = 0.3
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var freq = 900.0 if t < 0.07 else (1800.0 if t < 0.14 else 650.0)
				var tone = sin(2.0 * PI * freq * t) * 0.35
				var static_noise = (randf() * 2.0 - 1.0) * 0.15
				var env = 1.0 if t < 0.25 else (0.3 - t) / 0.05
				var val = clampf((tone + static_noise) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"car_engine": # Motor aproximándose
			duration = 0.5
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = sin((float(i) / float(total_samples)) * PI)
				var motor = sin(2.0 * PI * 50.0 * t) * 0.45 + sin(2.0 * PI * 100.0 * t) * 0.25
				var noise = (randf() * 2.0 - 1.0) * 0.1
				var val = clampf((motor + noise) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"coin": # Sonido de campana de dinero
			duration = 0.25
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var env = exp(-t * 14.0)
				var bell = sin(2.0 * PI * 987.77 * t) * 0.45 + sin(2.0 * PI * 1318.5 * t) * 0.35
				var val = clampf(bell * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		"alarm": # Tono de alarma
			duration = 0.35
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var freq = 440.0 + sin(2.0 * PI * 8.0 * t) * 180.0
				var env = 0.4 if t < 0.3 else (0.35 - t) / 0.05
				var val = clampf(sin(2.0 * PI * freq * t) * env, -1.0, 1.0)
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

		_: # Sonido genérico
			duration = 0.08
			var total_samples = int(sample_rate * duration)
			data.resize(total_samples * 2)
			for i in range(total_samples):
				var t = float(i) / sample_rate
				var val = sin(2.0 * PI * 440.0 * t) * exp(-t * 25.0) * 0.4
				var s16 = int(val * 32767.0)
				data.encode_s16(i * 2, s16)

	wav.data = data
	return wav
