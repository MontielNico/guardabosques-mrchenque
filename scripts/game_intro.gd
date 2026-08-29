extends Control
class_name GameIntro

# Vista Introductoria Cinemática / Minimalista del Juego
# Diseño sin interfaz pesada: Fondo negro puro, texto blanco con palabras en color,
# efecto mecanográfico con audio y avance fluido entre el Prólogo y el Contexto de Mr. Chenque.

@onready var narrative_label: RichTextLabel = $Margin/VBox/NarrativeLabel
@onready var prompt_label: Label = $Margin/VBox/PromptContainer/PromptLabel
@onready var skip_hint: Label = $Margin/VBox/PromptContainer/SkipHint
@onready var menu_btn: Button = $Margin/TopBar/MenuButton

@export var typing_speed: float = 55.0 # Caracteres por segundo
var current_visible_chars: float = 0.0
var total_character_count: int = 0
var is_typing: bool = false
var last_sound_char_index: int = -1
var current_step: int = 0

# Páginas de la narrativa introductoria (Contenido original intacto)
var intro_screens: Array[Dictionary] = [
	{
		"id": "prologue_setting",
		"text": "[color=#a0d8ef]PATAGONIA AUSTRAL.[/color]\n\nEl viento gélido del océano Atlántico azota sin descanso los acantilados del [color=#ffe680]Cerro Chenque[/color].\n\nEn lo alto de la colina se erige el histórico [color=#5af78e]Chalet Huergo[/color] y sus 5 parcelas protegidas: un santuario natural que combina vegetación nativa de lengas, colonias de pingüinos de Magallanes, humedales y vestigios de la vieja infraestructura petrolera.\n\nUn puesto solitario, frío y cargado de secretos que la niebla marina intenta ocultar..."
	},
	{
		"id": "mr_chenque_context",
		"text": "Me llamo [color=#ffe680]Mr. Chenque[/color]. El trabajo no era complicado. Eso fue lo primero que me dijeron: controlar los accesos, revisar permisos, vigilar que nadie se llevara lo que no debía y mantener a los turistas dentro de las zonas habilitadas. Nada extraordinario; después de todo, alguien tenía que hacerlo.\n\nEl Parque Nacional Chalet Huergo no es un lugar como los demás: acantilados sobre el Atlántico, viento casi todo el año, vegetación nativa y los restos de una época en la que el petróleo todavía estaba cambiando la ciudad. Un lugar viejo, aislado pero tranquilo. O eso dicen.\n\nAcepté el puesto porque siempre me importaron la flora y la fauna de este lugar. Desde chico aprendí a reconocer sus especies, sus ciclos y las pequeñas señales que otros no suelen notar. Por eso no pude ignorar lo que estaba pasando: el parque se había quedado sin guardaparque y, con el tiempo, la vegetación y los animales empezaron a desaparecer. Cada temporada había menos: menos nidos, menos huellas y menos brotes en las zonas donde antes crecían plantas nativas. No podía quedarme mirando cómo el parque se apagaba, así que acepté el trabajo; no por el dinero, sino porque alguien tenía que estar acá.\n\nMañana empieza mi primer turno. Me dijeron que el guardabosques anterior dejó todo preparado: la libreta, los registros y las llaves deberían estar en la garita. Solo tengo que seguir las reglas y cuidar el parque. Eso no debería ser difícil."
	}
]

func _ready() -> void:
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
	_start_screen(0)

func _start_screen(step_idx: int) -> void:
	if step_idx < 0 or step_idx >= intro_screens.size():
		_finish_intro()
		return
		
	current_step = step_idx
	var screen_data = intro_screens[step_idx]
	
	if prompt_label:
		prompt_label.visible = false
	if skip_hint:
		skip_hint.visible = true
		skip_hint.text = "[ ESPACIO / CLICK: Completar texto ]"
		
	if narrative_label:
		narrative_label.text = screen_data.get("text", "")
		narrative_label.visible_characters = 0
		total_character_count = narrative_label.get_total_character_count()
		narrative_label.scroll_to_line(0)
		var v_scroll = narrative_label.get_v_scroll_bar()
		if v_scroll:
			v_scroll.value = 0
		
	current_visible_chars = 0.0
	last_sound_char_index = -1
	is_typing = true

func _process(delta: float) -> void:
	if is_typing:
		current_visible_chars += typing_speed * delta
		var char_int = int(current_visible_chars)
		
		if narrative_label:
			narrative_label.visible_characters = char_int
			
		if char_int > last_sound_char_index and char_int <= total_character_count:
			if char_int % 2 == 0:
				SoundManager.play_sound("typewriter_key")
			last_sound_char_index = char_int
			
		if char_int >= total_character_count:
			_on_typing_completed()

func _on_typing_completed() -> void:
	is_typing = false
	if narrative_label:
		narrative_label.visible_characters = -1
	SoundManager.play_sound("typewriter_return")
	
	if skip_hint:
		skip_hint.visible = false
	if prompt_label:
		prompt_label.visible = true
		if current_step == 0:
			prompt_label.text = "[ PRESIONA ESPACIO O HAZ CLICK PARA CONTINUAR ▶ ]"
		else:
			prompt_label.text = "[ PRESIONA ESPACIO O HAZ CLICK PARA ASUMIR EL PUESTO ▶ ]"

func _complete_current_typing() -> void:
	if is_typing:
		current_visible_chars = float(total_character_count)
		if narrative_label:
			narrative_label.visible_characters = total_character_count
		_on_typing_completed()

func _next_step() -> void:
	SoundManager.play_sound("click")
	if current_step + 1 < intro_screens.size():
		_start_screen(current_step + 1)
	else:
		_finish_intro()

func _finish_intro() -> void:
	# Al finalizar el contexto de Mr. Chenque, avanzamos al briefing de órdenes del Día 1
	GameManager.play_day_intro(1)

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if is_typing:
				_complete_current_typing()
			else:
				_next_step()
		elif event.keycode == KEY_ESCAPE:
			_finish_intro()
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			_complete_current_typing()
		else:
			_next_step()
