extends Control
class_name DayIntro

# Escena de Introducción Narrativa y Apertura de Jornada Diaria
# Estética retro de terminal / teletype con fondo oscuro, tipografía pixel y efecto mecanográfico (Typing Text).

@onready var background_panel: Panel = $Background
@onready var agency_badge: Label = $Margin/Card/CardMargin/VBox/Header/AgencyRow/AgencyBadge
@onready var page_counter: Label = $Margin/Card/CardMargin/VBox/Header/AgencyRow/PageCounter
@onready var title_label: Label = $Margin/Card/CardMargin/VBox/Header/TitleLabel
@onready var subtitle_label: Label = $Margin/Card/CardMargin/VBox/Header/SubtitleLabel
@onready var text_label: RichTextLabel = $Margin/Card/CardMargin/VBox/ContentBox/MarginText/HBox/RichTextLabel
# @onready var cursor_label: Label = $Margin/Card/CardMargin/VBox/ContentBox/MarginText/HBox/CursorLabel
@onready var skip_hint: Label = $Margin/Card/CardMargin/VBox/Footer/SkipHint
@onready var menu_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/MenuButton
@onready var fast_forward_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/FastForwardButton
@onready var continue_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/ContinueButton

# Variables de control del efecto Typing Text
@export var typing_speed: float = 36.0 # Caracteres por segundo
var current_visible_chars: float = 0.0
var total_character_count: int = 0
var is_typing: bool = false
var last_sound_char_index: int = -1
var cursor_blink_timer: float = 0.0

# Datos de las páginas a mostrar
var pages: Array[Dictionary] = []
var current_page_index: int = 0
var next_scene_path: String = "res://scenes/main_game.tscn"

func _ready() -> void:
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
	if fast_forward_btn:
		fast_forward_btn.pressed.connect(_complete_current_page_typing)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
		
	_setup_intro_content()
	_start_page(0)

func _setup_intro_content() -> void:
	# Determinar si cargamos Prólogo, Día específico o configuración de GameManager
	var mode = "day"
	var target_day = GameManager.current_day
	
	if GameManager.get("intro_mode") != null:
		mode = GameManager.intro_mode
		
	if mode == "prologue":
		pages = _get_prologue_pages()
		next_scene_path = "res://scenes/main_game.tscn"
	elif mode == "custom" and GameManager.get("custom_intro_pages") != null:
		pages = GameManager.custom_intro_pages
		if GameManager.get("custom_next_scene") != null:
			next_scene_path = GameManager.custom_next_scene
	else:
		pages = _get_day_pages(target_day)
		next_scene_path = "res://scenes/main_game.tscn"

func _get_prologue_pages() -> Array[Dictionary]:
	return [
		{
			"agency": "ADMINISTRACIÓN DE PARQUES NACIONALES - SECTOR COSTA ATLÁNTICA",
			"title": "═══ PRÓLOGO: EL PUESTO EN EL CHALET HUERGO ═══",
			"subtitle": "📍 COMODORO RIVADAVIA, PATAGONIA ARGENTINA | 45°51'S 67°28'W",
			"text": "[color=#a0d8ef]PATAGONIA AUSTRAL.[/color]\n\nEl viento gélido del océano Atlántico azota sin descanso los acantilados del [color=#ffe680]Cerro Chenque[/color].\n\nEn lo alto de la colina se erige el histórico [color=#5af78e]Chalet Huergo[/color] y sus 5 parcelas protegidas: un santuario natural que combina vegetación nativa de lengas, colonias de pingüinos de Magallanes, humedales y vestigios de la vieja infraestructura petrolera.\n\nUn puesto solitario, frío y cargado de secretos que la niebla marina intenta ocultar...",
			"button_text": "SIGUIENTE REPORTE ▶"
		},
		{
			"agency": "DIRECCIÓN DE RECURSOS NATURALES - DESIGNACIÓN DE PERSONAL",
			"title": "═══ EXPEDIENTE: GUARDAPARQUES MR. CHENQUE ═══",
			"subtitle": "📋 ORDEN DE SERVICIO DE 5 DÍAS | COBERTURA DE PUESTO VACANTE",
			"text": "Te llamas [color=#ffe680]Mr. Chenque[/color]. Aceptaste este puesto por pura necesidad económica: tu familia en la ciudad depende del sueldo y los bonos de cada jornada para afrontar el crudo invierno patagónico.\n\nTu antecesor, el [color=#ff7777]Guardabosques Silva[/color], desapareció misteriosamente el martes pasado a mitad de su turno. Dejó la cafetera a medio llenar, la libreta de bitácora abierta en el escritorio... y la puerta de la garita sin llave.\n\nTu misión es rigurosa: controlar cada vehículo que arriba a la barrera, verificar pases y permisos de fuego, inspeccionar baúles e impedir la caza furtiva y el contrabando.\n\n[color=#ff5555]No permitas el ingreso de nadie que no cumpla estrictamente el reglamento.[/color]",
			"button_text": "LEER ÓRDENES DEL DÍA 1 ▶"
		},
		_get_day_briefing_dict(1)
	]

func _get_day_pages(day_num: int) -> Array[Dictionary]:
	return [
		_get_day_briefing_dict(day_num)
	]

func _get_day_briefing_dict(day_num: int) -> Dictionary:
	match day_num:
		1:
			return {
				"agency": "SECCIONAL PARQUE CHALET HUERGO - PARTE OPERATIVO DIARIO",
				"title": "═══ DÍA 1: LUNES - APERTURA DE JORNADA ═══",
				"subtitle": "💨 CLIMA: Viento O/SO 50 km/h - Parcialmente nublado | 🔥 RIESGO FUEGO: MEDIO",
				"text": "[color=#ffe680]LUNES - PRIMAVERA VENTOSA.[/color]\n\nPrimer día de servicio en la garita principal. La temporada arranca con trámites habituales: visitantes locales, fotógrafos, científicos y recolectores.\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL:[/color]\n1. Todo visitante debe portar [color=#ffffff]Pase de Ingreso Diario[/color] con fecha vigente.\n2. Fuego permitido [color=#ffcc66]ÚNICAMENTE con Permiso de Fuego explícito[/color].\n3. Prohibido acampar en zonas protegidas sin permiso especial.\n4. La cantidad de pasajeros reales debe coincidir con lo declarado en el pase.\n\n[color=#a8b5c2]• ANOTACIÓN ENCONTRADA EN LA BITÁCORA DE SILVA:[/color]\n[color=#99eebb]El viento del acantilado suena distinto a las 3:00 AM. Hoy bajé a revisar las cuevas bajo el Chalet. Hay marcas recientes en las rocas...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 1"
			}
		2:
			return {
				"agency": "SECCIONAL PARQUE CHALET HUERGO - ALERTA METEOROLÓGICA",
				"title": "═══ DÍA 2: MARTES - ALERTA POR SEQUÍA Y VEDA ═══",
				"subtitle": "💨 CLIMA: Viento Norte 35 km/h - Seco y caluroso (27°C) | 🔥 RIESGO FUEGO: ALTO",
				"text": "[color=#ff9944]MARTES - ALERTA POR SEQUÍA Y CALOR.[/color]\n\nLas altas temperaturas y la sequedad extrema elevan el riesgo de incendio forestal en las 5 parcelas a nivel [color=#ff4444]ALTO[/color].\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL ESTRICTAS:[/color]\n1. [color=#ff5555]PROHIBICIÓN TOTAL DE FUEGO, CARBÓN O LEÑA[/color] (Incluso si traen permisos anteriores).\n2. Pesca deportiva permitida [color=#5af78e]SOLO con Permiso de Pesca Provincial vigente[/color].\n3. Prohibidas las redes agalleras, arpones y elementos de pesca furtiva.\n4. Pasa a [color=#ffe680]Vista 2 (Inspección de Baúl)[/color] para verificar cargas sospechosas.\n\n[color=#a8b5c2]• NOTA EN EL SEGUNDO CAJÓN DE SILVA:[/color]\n[color=#99eebb]No los dejes llevarse nada del lecho del acantilado ni de la restinga. Se alimentan de eso...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 2"
			}
		3:
			return {
				"agency": "DEFENSA CIVIL Y PARQUES NACIONALES - ALERTA ROJA",
				"title": "═══ DÍA 3: MIÉRCOLES - TEMPORAL PATAGÓNICO ═══",
				"subtitle": "💨 CLIMA: Viento O/NO 90 km/h (Temporal Extremo) | 🔥 RIESGO: EXTREMO",
				"text": "[color=#ff4444]MIÉRCOLES - TEMPORAL DE VIENTO Y NIEBLA COSTERA.[/color]\n\nRáfagas de 90 km/h azotan la costa de Comodoro. La arena y el polvo cubren el asfalto y una densa niebla sube desde el mar.\n\n[color=#7be5ff]• DIRECTIVAS DE EMERGENCIA:[/color]\n1. [color=#ff5555]PROHIBICIÓN TOTAL DE MOTOSIERRAS, HACHAS, LEÑA Y BIDONES DE NAFTA[/color] (Riesgo de tala y desastre por fuego).\n2. [color=#ffe680]Máximo 4 pasajeros por vehículo[/color] para permitir evacuaciones de emergencia.\n3. Verificar con rigurosidad las fechas de vencimiento de la documentación.\n4. Interroga a conductores que justifiquen traslados nocturnos.\n\n[color=#a8b5c2]• ADVERTENCIA DE RADIO:[/color]\n[color=#99eebb]Silva pensó que podía decirles que no en plena niebla. Mantén la calma Chenque...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 3"
			}
		4:
			return {
				"agency": "SECCIONAL PARQUE CHALET HUERGO - PROTOCOLO DE CONSERVACIÓN",
				"title": "═══ DÍA 4: JUEVES - ANOMALÍAS Y PROTECCIÓN DE FAUNA ═══",
				"subtitle": "💨 CLIMA: Viento Sur 40 km/h - Frío y llovizna (11°C) | ⚠️ RIESGO: CAZA Y USURPACIÓN",
				"text": "[color=#7be5ff]JUEVES - OTOÑO INICIAL Y MAREA ANORMAL.[/color]\n\nLa marea alta golpea la base del Cerro Chenque y el suelo del puesto parece vibrar con una extraña frecuencia continua.\n\n[color=#7be5ff]• DIRECTIVAS DE PRESERVACIÓN:[/color]\n1. [color=#ff5555]TOLERANCIA CERO A LA CAZA FURTIVA:[/color] Rifles, gomeras, trampas o jaulas = [color=#ff5555]RECHAZO INMEDIATO[/color].\n2. [color=#ffaa44]Prohibido transportar materiales de construcción o alambre de púa[/color] sin orden de catastro (Riesgo de usurpación).\n3. Mascotas permitidas únicamente con correa reglamentaria para resguardar a los pingüinos.\n4. Verifica que la fotografía y datos del documento coincidan con el rostro del conductor.\n\n[color=#a8b5c2]• LIBRETA DE SILVA (ÚLTIMA PÁGINA ARRANCADA):[/color]\n[color=#99eebb]Los túneles bajo el Chalet conectan directo con la rompiente. No están solos...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 4"
			}
		5:
			return {
				"agency": "MINISTERIO Y ADMINISTRACIÓN NACIONAL - AUDITORÍA GENERAL",
				"title": "═══ DÍA 5: VIERNES - EL ÚLTIMO GUARDIA ═══",
				"subtitle": "💨 CLIMA: Viento SO 65 km/h - Helada matinal (7°C) | 🚨 AUDITORÍA FINAL",
				"text": "[color=#ffe680]VIERNES - ÚLTIMO DÍA DE SERVICIO Y CLÍMAX.[/color]\n\nEl silencio en la garita es sepulcral. Nadie contesta las llamadas por la frecuencia de radio oficial.\n\n[color=#7be5ff]• APLICACIÓN INTEGRAL DE PROTOCOLOS:[/color]\n1. Aplica [color=#ffffff]todas las normativas aprendidas en la semana[/color]: control de fuego, carnet de pesca y habilitaciones de oficio.\n2. [color=#ff4444]ATENCIÓN EXTREMA A CREDENCIALES FALSAS Y SUPLANTACIONES DE IDENTIDAD (DOPPELGÄNGERS)[/color].\n3. Exige órdenes de servicio válidas a todo vehículo que alegue inspección o mantenimiento.\n4. Tu balance económico final y la conservación de las 5 parcelas definirán tu destino como Guardaparques.\n\n[color=#5af78e]¡La Patagonia y tu familia cuentan con tu integridad, Mr. Chenque![/color]",
				"button_text": "▶ ASUMIR TURNO FINAL (DÍA 5)"
			}
		_:
			return {
				"agency": "PARQUE NACIONAL CHALET HUERGO",
				"title": "═══ REPORTE DE GUARDAPARQUES ═══",
				"subtitle": "PUESTO DE CONTROL DE ACCESO",
				"text": "Iniciando jornada operativa...",
				"button_text": "CONTINUAR ▶"
			}

func _start_page(page_idx: int) -> void:
	if page_idx < 0 or page_idx >= pages.size():
		_finish_intro()
		return
		
	current_page_index = page_idx
	var page_data = pages[page_idx]
	
	if agency_badge:
		agency_badge.text = page_data.get("agency", "PARQUE NACIONAL CHALET HUERGO")
	if title_label:
		title_label.text = page_data.get("title", "REPORTE OFICIAL")
	if subtitle_label:
		subtitle_label.text = page_data.get("subtitle", "")
	if page_counter:
		page_counter.text = "REGISTRO %d DE %d" % [page_idx + 1, pages.size()]
	if continue_btn:
		continue_btn.text = page_data.get("button_text", "CONTINUAR ▶")
		continue_btn.visible = false
		continue_btn.disabled = true
	if fast_forward_btn:
		fast_forward_btn.visible = true
	if skip_hint:
		skip_hint.visible = true
		skip_hint.text = "[ ESPACIO / CLICK: Completar texto ]"
		
	# Configurar texto de BBCode
	if text_label:
		text_label.text = page_data.get("text", "")
		text_label.visible_characters = 0
		total_character_count = text_label.get_total_character_count()
		
	current_visible_chars = 0.0
	last_sound_char_index = -1
	is_typing = true

func _process(delta: float) -> void:
	# Parpadeo del cursor retro
	cursor_blink_timer += delta
	
		
	if is_typing:
		current_visible_chars += typing_speed * delta
		var char_int = int(current_visible_chars)
		
		if text_label:
			text_label.visible_characters = char_int
			
		# Reproducir sonido de tecleo de máquina de escribir mecánicamente
		if char_int > last_sound_char_index and char_int <= total_character_count:
			# Reproducir sonido cada 2 caracteres para no saturar el buffer
			if char_int % 2 == 0:
				SoundManager.play_sound("typewriter_key")
			last_sound_char_index = char_int
			
		if char_int >= total_character_count:
			_on_typing_finished()

func _on_typing_finished() -> void:
	is_typing = false
	if text_label:
		text_label.visible_characters = -1 # Mostrar todo
	SoundManager.play_sound("typewriter_return")
	
	if continue_btn:
		continue_btn.visible = true
		continue_btn.disabled = false
		continue_btn.grab_focus()
	if fast_forward_btn:
		fast_forward_btn.visible = false
	if skip_hint:
		skip_hint.text = "[ ENTER / ESPACIO: Continuar ]"

func _complete_current_page_typing() -> void:
	if is_typing:
		current_visible_chars = float(total_character_count)
		if text_label:
			text_label.visible_characters = total_character_count
		_on_typing_finished()

func _on_continue_pressed() -> void:
	SoundManager.play_sound("click")
	if current_page_index + 1 < pages.size():
		_start_page(current_page_index + 1)
	else:
		_finish_intro()

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _finish_intro() -> void:
	# Al terminar la introducción, pasamos a la escena de juego principal o configurada
	get_tree().change_scene_to_file(next_scene_path)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if is_typing:
				_complete_current_page_typing()
			else:
				_on_continue_pressed()
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			_complete_current_page_typing()
