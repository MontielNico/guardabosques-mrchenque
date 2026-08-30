extends Control
class_name DayStartIntro

# Vista Introductoria Diaria (Inicio de Turno y Expectativas de Mr. Chenque)
# Diseño relajado y atmosférico con fondo oscuro, texto blanco con palabras en color,
# efecto mecanográfico con audio y espacio para textos personalizados por día.

@onready var day_badge: Label = $Margin/VBox/Header/DayBadge
@onready var narrative_label: RichTextLabel = $Margin/VBox/NarrativeLabel
@onready var prompt_label: Label = $Margin/VBox/PromptContainer/PromptLabel
@onready var skip_hint: Label = $Margin/VBox/PromptContainer/SkipHint
@onready var menu_btn: Button = $Margin/TopBar/MenuButton

@export var typing_speed: float = 55.0 # Caracteres por segundo
var current_visible_chars: float = 0.0
var total_character_count: int = 0
var is_typing: bool = false
var last_sound_char_index: int = -1
var target_day: int = 1

# ==============================================================================
# TEXTOS EDITABLES POR DÍA: INICIO DE TURNO Y EXPECTATIVAS DE MR. CHENQUE (DÍAS 2 AL 5)
# (El Día 1 inicia directamente tras la presentación del juego)
# ==============================================================================
var chenque_morning_texts: Dictionary = {
	2: """[color=#a0d8ef]06:50 — Inicio del turno, Segundo día.[/color]
	Ayer no pasó nada fuera de lo común. Si todos los días fueran así, creo que podría acostumbrarme rápido a este trabajo.
	Aunque anoche me costó un poco dormir. Hoy debería ser igual de tranquilo... o eso espero. 
	Al llegar revisé los cajones del escritorio de la cabina y encontré 2 notas bastante particulares. Estaban escritas a mano y la letra no me resulta conocida:
	'10/10/2010: El viento del acantilado suena distinto a las 3:00 AM. Hoy bajé a revisar las cuevas bajo el Chalet. Hay marcas en las rocas.'
	Coincide con ser la ultima guardia de Silva, pero la siguiente nota me dejó un poco más preocupado:
	'7/10/2010: No los dejes llevarse nada del lecho del acantilado. Se alimentan de eso.'
	No explica nada más. No sé qué espécimen encontró ni por qué le importa tanto. Supongo que hoy lo averiguaré.
	[color=#a0d8ef]06:55 — Comienza el turno.""",

	3: """[color=#a0d8ef]06:47 — Inicio del turno, Tercer día.[/color]
	No dormí demasiado bien anoche. Intenté convencerme de que lo de ayer fue solamente una rareza. Un pescador con un hallazgo extraño. Una nota del anterior guardaparque y nada más.
	Pero hoy no pude evitar mirar dos veces la puerta antes de entrar. Ayer luego de encontrar esas 2 notas dejé de revisar cajones, pero hoy para matar el tiempo terminé de revisar unos cajones más y encontre otra nota.La letra es la misma.
	'Ese agente no me genera nada bueno y viene siempre.'
	Nada más. No dice quién es el agente. No dice qué busca. Solo eso.
	Si realmente viene siempre, tarde o temprano voy a conocerlo, Espero que hoy no sea ese día…
	El día de hoy el día es bastante gris y hay una neblina muy espesa en el ambiente.
	[color=#a0d8ef]06:52 — Comienza el turno.""",

	4: """[color=#a0d8ef]06:38 — Inicio del turno, Cuarto día.[/color]
	Anoche casi no dormí. La marejada estuvo golpeando los acantilados durante horas. En algún momento sentí que toda la garita temblaba.
	Probablemente fue un desprendimiento, eso sería lo lógico.
	Hoy llueve y el mar sigue bastante agitado. Desde la ventana apenas puedo ver el acantilado. No sé qué me preocupa más: lo que está pasando afuera o lo que pueda encontrar cuando baje la marea.
	Solo quiero que termine el día.
	[color=#a0d8ef] 06:45 — Comienza el turno.
	""",

	5: """[color=#a0d8ef]06:31 — Inicio del turno Quinto día.[/color]
	No sé por qué volví. Después de lo que encontré ayer, lo sensato habría sido no acercarme nunca más a este lugar.
	Pero no pude hacerlo. Este parque sigue siendo mi responsabilidad. La flora, los animales, los acantilados... todo esto merece ser protegido, aunque yo ya no sepa de qué.
	Tengo miedo. Sé que algo está pasando y también sé que mi vida podría estar en peligro. Pero quizás todavía tenga suerte.
	Quizás pueda terminar este turno, cerrar la garita y volver a casa.
	Quizás, por una vez, las cosas puedan quedarse como están.
	Solo necesito aguantar un día más.
	[color=#a0d8ef]06:35 — Comienza el último turno.
	"""
}

func _ready() -> void:
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
		
	target_day = GameManager.current_day
	if target_day <= 1:
		GameManager.play_day_briefing(1)
		return
	_setup_day_morning(target_day)

func _setup_day_morning(day_num: int) -> void:
	target_day = day_num
	if target_day <= 1:
		GameManager.play_day_briefing(1)
		return
	
	# Audio según Plan Audio: Lunes/Martes -> Ambient | Miércoles/Jueves/Viernes -> Investigation
	SoundManager.play_day_intro_music(target_day)
	
	if day_badge:
		day_badge.text = "═══ DÍA %d: INICIO DE TURNO LABORAL ═══" % day_num
		
	if prompt_label:
		prompt_label.visible = false
	if skip_hint:
		skip_hint.visible = true
		skip_hint.text = "[ ESPACIO / CLICK: Completar texto ]"
		
	# Obtener texto matutino (permite override desde GameManager si existe)
	var text_to_show = ""
	if GameManager.get("custom_morning_texts") != null and GameManager.custom_morning_texts.has(day_num):
		text_to_show = GameManager.custom_morning_texts[day_num]
	else:
		text_to_show = chenque_morning_texts.get(day_num, "Iniciando jornada laboral del Día %d en la garita del Parque Chalet Huergo..." % day_num)
		
	if narrative_label:
		narrative_label.text = text_to_show
		narrative_label.visible_characters = 0
		total_character_count = narrative_label.get_total_character_count()
		
	current_visible_chars = 0.0
	last_sound_char_index = -1
	is_typing = true

func _process(delta: float) -> void:
	if is_typing:
		current_visible_chars += typing_speed * delta
		var char_int = int(current_visible_chars)
		
		if narrative_label:
			narrative_label.visible_characters = char_int
			
		if char_int >= total_character_count:
			_on_typing_completed()
		elif char_int > last_sound_char_index:
			if char_int % 2 == 0:
				SoundManager.play_sound("typewriter_key")
			last_sound_char_index = char_int

func _on_typing_completed() -> void:
	is_typing = false
	if narrative_label:
		narrative_label.visible_characters = -1
	SoundManager.play_sound("typewriter_return")
	
	if skip_hint:
		skip_hint.visible = false
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = "[ PRESIONA ESPACIO O HAZ CLICK PARA REVISAR DIRECTIVAS DEL DÍA %d ▶ ]" % target_day

func _complete_current_typing() -> void:
	if is_typing:
		current_visible_chars = float(total_character_count)
		if narrative_label:
			narrative_label.visible_characters = total_character_count
		_on_typing_completed()

func _proceed_to_day_briefing() -> void:
	SoundManager.play_sound("click")
	# Pasa al reporte operativo y directivas de control del día
	GameManager.play_day_briefing(target_day)

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Método público para permitir insertar texto dinámicamente desde cualquier script
func set_morning_text(day_num: int, text: String) -> void:
	chenque_morning_texts[day_num] = text
	if day_num == target_day and narrative_label:
		narrative_label.text = text

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if is_typing:
				_complete_current_typing()
			else:
				_proceed_to_day_briefing()
		elif event.keycode == KEY_ESCAPE:
			_proceed_to_day_briefing()
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			_complete_current_typing()
		else:
			_proceed_to_day_briefing()
