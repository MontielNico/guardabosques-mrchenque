extends Node

# SoundManager - Generador procedural de efectos de sonido en GDScript
# No requiere archivos de audio externos, crea los samples directamente en memoria.

var sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

# Pistas de música según el Plan Audio
const MUSIC_PATHS = {
	"ambient": "res://public/audio/Ambient _Guardaparque Game Soundtrack_.mp3",
	"investigation": "res://public/audio/(Fast)_Investigation__Guardaparque_Game_Soundtrack_.mp3",
	"jazz_radio": "res://public/audio/Jazz__Radio_.mp3"
}

var music_player_a: AudioStreamPlayer = null
var music_player_b: AudioStreamPlayer = null
var active_player: AudioStreamPlayer = null
var music_tween_a: Tween = null
var music_tween_b: Tween = null
var current_track_key: String = ""
var music_cache: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Pool de efectos de sonido
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)
		
	# Dos reproductores para cross-fade perfecto sin vacíos de audio
	music_player_a = AudioStreamPlayer.new()
	music_player_a.bus = "Master"
	add_child(music_player_a)
	
	music_player_b = AudioStreamPlayer.new()
	music_player_b.bus = "Master"
	add_child(music_player_b)
	
	active_player = music_player_a
	
	# Precarga de pistas musicales con loop activado
	for key in MUSIC_PATHS:
		var path = MUSIC_PATHS[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream is AudioStreamMP3:
				stream.loop = true
			music_cache[key] = stream

# ==============================================================================
# MÉTODOS DE CONTROL DE MÚSICA (CROSS-FADE SIN SILENCIOS)
# ==============================================================================

## Reproduce una pista de música con cross-fade suave
func play_music(track_key: String, fade_duration: float = 1.2, target_volume_db: float = -6.0) -> void:
	var stream = _get_or_load_stream(track_key)
	if stream == null:
		return

	# Si ya está sonando la misma pista en el reproductor activo
	if current_track_key == track_key and active_player and active_player.playing:
		if active_player.volume_db < target_volume_db:
			var tw = _get_tween_for_player(active_player)
			if tw and tw.is_valid():
				tw.kill()
			tw = create_tween()
			tw.tween_property(active_player, "volume_db", target_volume_db, fade_duration)
			_set_tween_for_player(active_player, tw)
		return

	current_track_key = track_key
	var outgoing_player = active_player
	var incoming_player = music_player_b if active_player == music_player_a else music_player_a
	active_player = incoming_player

	# Desvanecer reproductor saliente sin cortar el audio de golpe
	if outgoing_player and outgoing_player.playing:
		var out_tw = _get_tween_for_player(outgoing_player)
		if out_tw and out_tw.is_valid():
			out_tw.kill()
		out_tw = create_tween()
		out_tw.set_trans(Tween.TRANS_SINE)
		out_tw.set_ease(Tween.EASE_IN)
		out_tw.tween_property(outgoing_player, "volume_db", -80.0, maxf(0.8, fade_duration * 0.8))
		out_tw.tween_callback(func():
			if is_instance_valid(outgoing_player) and outgoing_player != active_player:
				outgoing_player.stop()
		)
		_set_tween_for_player(outgoing_player, out_tw)

	# Iniciar reproductor entrante con crossfade inmediato
	var in_tw = _get_tween_for_player(incoming_player)
	if in_tw and in_tw.is_valid():
		in_tw.kill()

	incoming_player.stream = stream
	# Arrancar en volumen sutil audible (-36 dB) para evitar el segundo de silencio digital
	incoming_player.volume_db = -36.0 if fade_duration > 0.0 else target_volume_db
	incoming_player.play()

	if fade_duration > 0.0:
		in_tw = create_tween()
		in_tw.set_trans(Tween.TRANS_SINE)
		in_tw.set_ease(Tween.EASE_OUT)
		in_tw.tween_property(incoming_player, "volume_db", target_volume_db, fade_duration)
		_set_tween_for_player(incoming_player, in_tw)

## Lógica de pista por día:
## - Menú hasta Día 2 (Martes): Ambient
## - Día 3 (Miércoles) hasta Game Over: Investigation
func play_music_for_day(day_num: int) -> void:
	if day_num <= 2:
		play_music("ambient", 1.2, -6.0)
	else:
		play_music("investigation", 1.2, -6.0)

func play_day_intro_music(day_num: int) -> void:
	play_music_for_day(day_num)

## Transición especial de menos a más para Game Over con Jazz_Radio (Cross-fade continuo)
func play_jazz_radio_game_over(fade_duration: float = 3.5, target_volume_db: float = -4.0) -> void:
	if current_track_key == "jazz_radio" and active_player and active_player.playing:
		return

	current_track_key = "jazz_radio"
	var stream = _get_or_load_stream("jazz_radio")
	if stream == null:
		return

	var outgoing_player = active_player
	var incoming_player = music_player_b if active_player == music_player_a else music_player_a
	active_player = incoming_player

	# El audio previo (Investigation) baja de volumen gradualmente en 2.0s
	if outgoing_player and outgoing_player.playing:
		var out_tw = _get_tween_for_player(outgoing_player)
		if out_tw and out_tw.is_valid():
			out_tw.kill()
		out_tw = create_tween()
		out_tw.set_trans(Tween.TRANS_SINE)
		out_tw.set_ease(Tween.EASE_IN)
		out_tw.tween_property(outgoing_player, "volume_db", -80.0, 2.0)
		out_tw.tween_callback(func():
			if is_instance_valid(outgoing_player) and outgoing_player != active_player:
				outgoing_player.stop()
		)
		_set_tween_for_player(outgoing_player, out_tw)

	# Jazz_Radio inicia de forma inmediata a un volumen base suave y emerge de menos a más
	var in_tw = _get_tween_for_player(incoming_player)
	if in_tw and in_tw.is_valid():
		in_tw.kill()

	incoming_player.stream = stream
	incoming_player.volume_db = -32.0 # Nivel base audible sin corte
	incoming_player.play()

	in_tw = create_tween()
	in_tw.set_trans(Tween.TRANS_QUAD)
	in_tw.set_ease(Tween.EASE_OUT)
	in_tw.tween_property(incoming_player, "volume_db", target_volume_db, fade_duration)
	_set_tween_for_player(incoming_player, in_tw)

## Mutea y detiene la música con transición suave
func fade_out_music(duration: float = 1.2) -> void:
	if active_player and active_player.playing:
		var tw = _get_tween_for_player(active_player)
		if tw and tw.is_valid():
			tw.kill()
		if duration > 0.0:
			tw = create_tween()
			tw.set_trans(Tween.TRANS_SINE)
			tw.set_ease(Tween.EASE_IN)
			tw.tween_property(active_player, "volume_db", -80.0, duration)
			tw.tween_callback(func():
				if is_instance_valid(active_player):
					active_player.stop()
				current_track_key = ""
			)
			_set_tween_for_player(active_player, tw)
		else:
			active_player.stop()
			active_player.volume_db = -80.0
			current_track_key = ""

## Detiene la música inmediatamente en ambos canales
func stop_music() -> void:
	if music_tween_a and music_tween_a.is_valid():
		music_tween_a.kill()
	if music_tween_b and music_tween_b.is_valid():
		music_tween_b.kill()
	if music_player_a:
		music_player_a.stop()
		music_player_a.volume_db = -80.0
	if music_player_b:
		music_player_b.stop()
		music_player_b.volume_db = -80.0
	current_track_key = ""

func _get_or_load_stream(key: String) -> AudioStream:
	if music_cache.has(key):
		return music_cache[key]
	var path = MUSIC_PATHS.get(key, "")
	if not path.is_empty() and ResourceLoader.exists(path):
		var stream = load(path)
		if stream is AudioStreamMP3:
			stream.loop = true
		music_cache[key] = stream
		return stream
	return null

func _get_tween_for_player(player: AudioStreamPlayer) -> Tween:
	return music_tween_a if player == music_player_a else music_tween_b

func _set_tween_for_player(player: AudioStreamPlayer, tw: Tween) -> void:
	if player == music_player_a:
		music_tween_a = tw
	else:
		music_tween_b = tw


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
				var _t = float(i) / sample_rate
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
