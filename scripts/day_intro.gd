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
@onready var cursor_label: Label = $Margin/Card/CardMargin/VBox/ContentBox/MarginText/HBox/CursorLabel
@onready var skip_hint: Label = $Margin/Card/CardMargin/VBox/Footer/SkipHint
@onready var menu_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/MenuButton
@onready var fast_forward_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/FastForwardButton
@onready var continue_btn: Button = $Margin/Card/CardMargin/VBox/Footer/ButtonsBox/ContinueButton

# Variables de control del efecto Typing Text
@export var typing_speed: float = 60.0 # Caracteres por segundo
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
			"text": "Me llamo [color=#ffe680]Mr. Chenque[/color]. El trabajo no era complicado. Eso fue lo primero que me dijeron: controlar los accesos, revisar permisos, vigilar que nadie se llevara lo que no debía y mantener a los turistas dentro de las zonas habilitadas. Nada extraordinario; después de todo, alguien tenía que hacerlo.\n El Parque Nacional Chalet Huergo no es un lugar como los demás: acantilados sobre el Atlántico, viento casi todo el año, vegetación nativa y los restos de una época en la que el petróleo todavía estaba cambiando la ciudad. Un lugar viejo, aislado pero tranquilo. O eso dicen.\n Acepté el puesto porque siempre me importaron la flora y la fauna de este lugar. Desde chico aprendí a reconocer sus especies, sus ciclos y las pequeñas señales que otros no suelen notar. Por eso no pude ignorar lo que estaba pasando: el parque se había quedado sin guardaparque y, con el tiempo, la vegetación y los animales empezaron a desaparecer. Cada temporada había menos: menos nidos, menos huellas y menos brotes en las zonas donde antes crecían plantas nativas. No podía quedarme mirando cómo el parque se apagaba, así que acepté el trabajo; no por el dinero, sino porque alguien tenía que estar acá.\n Mañana empieza mi primer turno. Me dijeron que el guardabosques anterior dejó todo preparado: la libreta, los registros y las llaves deberían estar en la garita. Solo tengo que seguir las reglas y cuidar el parque. Eso no debería ser difícil.",
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
				"title": "═══ DÍA 1: LO BÁSICO - PRIMAVERA VENTOSA ═══",
				"subtitle": "💨 CLIMA: Viento O/SO 50 km/h - Parcialmente nublado | 🔥 RIESGO: MEDIO",
				"text": "[color=#ffe680]LUNES - LO BÁSICO.[/color]\n\nPrimer día de servicio en la garita principal. La temporada arranca con visitantes locales: solo [color=#ffffff]Turistas y Vecinos[/color].\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL:[/color]\n1. Documentos requeridos: [color=#ffffff]DNI y Pase de Visita Diario[/color].\n2. [color=#ff5555]LÓGICA DE ERROR:[/color] Validar que el DNI [color=#5af78e]NO esté vencido[/color].\n3. [color=#ff5555]LÓGICA DE ERROR:[/color] Validar que el [color=#5af78e]nombre coincida[/color] en ambos papeles.\n\n[color=#a8b5c2]• EVENTO DE TURNO:[/color]\nAl finalizar la jornada recibirás los papeles de relevo y la bitácora del anterior guardaparques...",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 1"
			}
		2:
			return {
				"agency": "SECCIONAL PARQUE CHALET HUERGO - VALIDACIÓN EXTENDIDA",
				"title": "═══ DÍA 2: VALIDACIÓN EXTENDIDA - TRABAJADORES ═══",
				"subtitle": "💨 CLIMA: Viento N 35 km/h - Seco y soleado (27°C) | 🔥 RIESGO: ALTO",
				"text": "[color=#ff9944]MARTES - VALIDACIÓN EXTENDIDA.[/color]\n\nNuevos ingresos a la seccional. A los turistas y vecinos se suman [color=#ffffff]Trabajadores[/color] (técnicos, guías, cuadrillas).\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL:[/color]\n1. Se agrega el [color=#ffe680]Permiso de Actividad[/color] (3 papeles en mesa: DNI, Pase y Permiso).\n2. [color=#ff5555]LÓGICA DE ERROR:[/color] Continúa igual que el primer día (DNI no vencido y coincidencia de nombres).\n3. Mayor cantidad de papeles en el escritorio para cotejar datos básicos.\n\n[color=#a8b5c2]• EVENTO NARRATIVO:[/color]\n[color=#99eebb]Atento a la llegada de un Pescador Raro que opera en las restingas del acantilado...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 2"
			}
		3:
			return {
				"agency": "DEFENSA CIVIL Y PARQUES NACIONALES - NIEBLA COSTERA",
				"title": "═══ DÍA 3: LA PALABRA VS EL PAPEL Y NIEBLA ═══",
				"subtitle": "🌫️ AMBIENTE: Niebla Densa del Atlántico | ⚠️ VISIBILIDAD REDUCIDA",
				"text": "[color=#a0d8ef]MIÉRCOLES - LA PALABRA VS EL PAPEL.[/color]\n\nUna densa niebla marina cubre todo el Chalet Huergo y los acantilados. Se suman [color=#ffffff]Científicos y Acampantes[/color].\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL:[/color]\n1. [color=#ff5555]LÓGICA DE ERROR: VALIDACIÓN DE DIÁLOGOS.[/color]\n2. El [color=#5af78e]diálogo del visitante DEBE coincidir con la Actividad Autorizada[/color] en su Permiso.\n3. [color=#ffe680]NO SE INCLUYE mecánica de inspección de baúl[/color]: Prioriza la declaración oral frente al papel.\n\n[color=#a8b5c2]• EVENTO DE MEDIANOCHE:[/color]\n[color=#ff7777]El último visitante es un Trabajador nocturno sin documentos válidos. Tu decisión tendrá consecuencias.[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 3"
			}
		4:
			return {
				"agency": "SECCIONAL PARQUE CHALET HUERGO - ALERTA MAREA ALTA",
				"title": "═══ DÍA 4: FALSIFICACIONES MÚLTIPLES Y MAREA ALTA ═══",
				"subtitle": "🌊 AMBIENTE: Marea Alta Anormal | ⏱️ RITMO: FILA RÁPIDA",
				"text": "[color=#7be5ff]JUEVES - FALSIFICACIONES MÚLTIPLES.[/color]\n\nLa marea alta azota la base del Cerro Chenque. Fila rápida con todos los casos mezclados bajo presión de tiempo.\n\n[color=#7be5ff]• DIRECTIVAS DE CONTROL:[/color]\n1. [color=#ff5555]LÓGICA DE ERROR: CONTROL INTEGRAL CRUZADO.[/color]\n2. Cruzar todos los datos visuales, DNI vigente, nombres y coherencia de diálogos.\n3. Atento a documentos anómalos que aparezcan mezclados por error.\n\n[color=#a8b5c2]• EVENTO OBLIGATORIO:[/color]\n[color=#99eebb]Circulan la legendaria fotografía de 1920 y el mapa de túneles bajo el Chalet Huergo...[/color]",
				"button_text": "▶ ABRIR GARITA Y COMENZAR DÍA 4"
			}
		5:
			return {
				"agency": "ADMINISTRACIÓN NACIONAL - CLÍMAX Y AUDITORÍA FINAL",
				"title": "═══ DÍA 5: EL LEGADO DE SILVA - DETECCIÓN DE ANOMALÍAS ═══",
				"subtitle": "🚨 DETECCIÓN DE ANOMALÍAS ACTIVADA | 🚪 DECISIÓN FINAL",
				"text": "[color=#ffe680]VIERNES - EL LEGADO DE SILVA.[/color]\n\nSilencio total en la radio de la garita. La niebla y la marea confluyen en el último turno.\n\n[color=#7be5ff]• LÓGICA DE ERROR - RECHAZO POR ANOMALÍAS:[/color]\n1. [color=#ff5555]RECHAZAR[/color] si el documento tiene [color=#ff5555]SELLO NEGRO[/color].\n2. [color=#ff5555]RECHAZAR[/color] si el documento está [color=#ff5555]FIRMADO POR SILVA[/color].\n3. [color=#ff5555]RECHAZAR[/color] si la [color=#ff5555]fecha es ilógica (ej. 1980 o 2099)[/color].\n\n[color=#a8b5c2]• EVENTO FINAL:[/color]\n[color=#ff7777]El último visitante es El Hombre Sin Rostro con documento de 1980. El destino de Mr. Chenque depende de ti.[/color]",
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
	if cursor_label:
		cursor_label.visible = int(cursor_blink_timer * 3.0) % 2 == 0
		
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
