extends Control
class_name GameOverScreen

# Pantalla de Conclusión de Servicio / Evaluación Final de Mr. Chenque (5 Días)

@onready var title_lbl: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var rank_lbl: Label = $Panel/Margin/VBox/RankBadge
@onready var desc_lbl: Label = $Panel/Margin/VBox/Description
@onready var stats_lbl: Label = $Panel/Margin/VBox/StatsDetail
@onready var retry_btn: Button = $Panel/Margin/VBox/Buttons/RetryButton
@onready var menu_btn: Button = $Panel/Margin/VBox/Buttons/MenuButton

func _ready() -> void:
	if retry_btn:
		retry_btn.pressed.connect(_on_retry_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
		
	var ending = GameManager.get_game_ending()
	
	if title_lbl:
		title_lbl.text = ending.get("title", "INFORME FINAL")
	if rank_lbl:
		rank_lbl.text = ending.get("icon", "🌲") + "  " + ending.get("rating", "")
		rank_lbl.modulate = ending.get("color", Color.WHITE)
	if desc_lbl:
		desc_lbl.text = ending.get("description", "")
		
	if stats_lbl:
		var avg_health = GameManager.get_average_parcel_health()
		stats_lbl.text = """═══════════════════════════════════════════════════════
• Conservación Promedio del Parque: %.1f%%
• Fondo Familiar Final Ahorrado: $%d
• Patrullajes de Emergencia Realizados: %d
• Infracciones Furtivas Neutralizadas: %d
═══════════════════════════════════════════════════════""" % [
			avg_health,
			GameManager.family_savings,
			GameManager.total_patrols_done,
			GameManager.total_infractors_stopped
		]

func _on_retry_pressed() -> void:
	SoundManager.play_sound("click")
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
