extends Control
class_name GameOverScreen

# Pantalla de Game Over / Evaluación Final de Mr. Chenque (5 Días)
# Estética retro 8-bits pura con fondo negro y aparición secuencial con efecto fade

@onready var section_title: VBoxContainer = $Margin/VBox/SectionTitle
@onready var section_rank: PanelContainer = $Margin/VBox/SectionRank
@onready var rank_lbl: Label = $Margin/VBox/SectionRank/RankLabel
@onready var section_desc: PanelContainer = $Margin/VBox/SectionDesc
@onready var desc_lbl: Label = $Margin/VBox/SectionDesc/DescriptionLabel
@onready var section_stats: PanelContainer = $Margin/VBox/SectionStats
@onready var stats_lbl: Label = $Margin/VBox/SectionStats/StatsLabel
@onready var section_buttons: HBoxContainer = $Margin/VBox/SectionButtons
@onready var retry_btn: Button = $Margin/VBox/SectionButtons/RetryButton
@onready var menu_btn: Button = $Margin/VBox/SectionButtons/MenuButton

var sequence_tween: Tween = null
var animation_completed: bool = false

func _ready() -> void:
	# Asegurar reproducción fluida de Jazz_Radio sin gaps
	SoundManager.play_jazz_radio_game_over(3.5, -4.0)

	if retry_btn:
		retry_btn.pressed.connect(_on_retry_pressed)
		retry_btn.disabled = true
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
		menu_btn.disabled = true

	# Obtener datos del final
	var ending = GameManager.get_game_ending()
	
	if rank_lbl:
		var rank_icon = ending.get("icon", "🌲")
		var rank_title = ending.get("title", "INFORME FINAL")
		var rank_rating = ending.get("rating", "")
		rank_lbl.text = "%s %s\n(%s)" % [rank_icon, rank_title, rank_rating]
		rank_lbl.modulate = ending.get("color", Color.WHITE)
		
	if desc_lbl:
		desc_lbl.text = ending.get("description", "")
		
	if stats_lbl:
		var avg_health = GameManager.get_average_parcel_health()
		var narrative_notes = ""
		if GameManager.day5_final_choice == "embrace_mystery":
			narrative_notes += "\n• LEGADO: Cruzaste la barrera hacia los túneles subterráneos."
		elif GameManager.day5_final_choice == "protect_park":
			narrative_notes += "\n• LEGADO: Garita clausurada y superficie del parque resguardada."
			
		if GameManager.day3_worker_decision == "approved_unease":
			narrative_notes += "\n• NIEBLA: Camión misterioso ingresó sin registro."
		elif GameManager.day3_worker_decision == "rejected_threat":
			narrative_notes += "\n• NIEBLA: Resististe las advertencias del conductor."
			
		if GameManager.photo_1920_discovered or GameManager.tunnels_map_discovered:
			narrative_notes += "\n• SECRETOS: Fotografía de 1920 y Mapa de Túneles recuperados."

		var collapsed_count = 0
		for p_name in GameManager.parcels_collapsed:
			if GameManager.parcels_collapsed[p_name]:
				collapsed_count += 1
		if collapsed_count > 0:
			narrative_notes += "\n• COLAPSO ECOLÓGICO: %d parcela(s) devastada(s) por completo bajo tu guardia." % collapsed_count

		stats_lbl.text = """• CONSERVACIÓN DE PARCELAS: %.1f%% | FONDO FAMILIAR: $%d
• INFRACTORES DETENIDOS: %d | ERRORES EN GARITA: %d%s""" % [
			avg_health,
			int(GameManager.family_savings),
			GameManager.total_infractors_stopped,
			GameManager.total_mistakes_made,
			narrative_notes
		]

	_start_fade_sequence()

func _start_fade_sequence() -> void:
	# Ocultar inicialmente todas las secciones para el fade in progresivo
	section_title.modulate.a = 0.0
	section_rank.modulate.a = 0.0
	section_desc.modulate.a = 0.0
	section_stats.modulate.a = 0.0
	section_buttons.modulate.a = 0.0
	
	sequence_tween = create_tween()
	
	# 1. Título principal "Game Over"
	sequence_tween.tween_property(section_title, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sequence_tween.tween_interval(0.3)
	
	# 2. Rango / Calificación del Guardaparque
	sequence_tween.tween_property(section_rank, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sequence_tween.tween_interval(0.3)
	
	# 3. Narrativa / Desenlace
	sequence_tween.tween_property(section_desc, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sequence_tween.tween_interval(0.3)
	
	# 4. Estadísticas del turno
	sequence_tween.tween_property(section_stats, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sequence_tween.tween_interval(0.35)
	
	# 5. Botones de acción
	sequence_tween.tween_property(section_buttons, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sequence_tween.tween_callback(func():
		animation_completed = true
		if retry_btn: retry_btn.disabled = false
		if menu_btn: menu_btn.disabled = false
	)

func _skip_fade_sequence() -> void:
	if animation_completed:
		return
	if sequence_tween and sequence_tween.is_valid():
		sequence_tween.kill()
	section_title.modulate.a = 1.0
	section_rank.modulate.a = 1.0
	section_desc.modulate.a = 1.0
	section_stats.modulate.a = 1.0
	section_buttons.modulate.a = 1.0
	if retry_btn: retry_btn.disabled = false
	if menu_btn: menu_btn.disabled = false
	animation_completed = true

func _unhandled_input(event: InputEvent) -> void:
	if not animation_completed:
		if (event is InputEventKey and event.is_pressed() and not event.is_echo()) or (event is InputEventMouseButton and event.is_pressed()):
			_skip_fade_sequence()

func _on_retry_pressed() -> void:
	SoundManager.play_sound("click")
	GameManager.play_prologue()

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	SoundManager.play_music("ambient", 1.2, -6.0)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
