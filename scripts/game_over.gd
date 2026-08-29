extends Control
class_name GameOverScreen

# Pantalla de Conclusión de Servicio / Evaluación Final de Mr. Chenque (5 Días)

@onready var title_lbl: Label = $Margin/Panel/InnerMargin/VBox/Header/TitleLabel
@onready var rank_lbl: Label = $Margin/Panel/InnerMargin/VBox/RankBadge
@onready var desc_lbl: Label = $Margin/Panel/InnerMargin/VBox/Description
@onready var stats_lbl: Label = $Margin/Panel/InnerMargin/VBox/StatsDetail
@onready var retry_btn: Button = $Margin/Panel/InnerMargin/VBox/Buttons/RetryButton
@onready var menu_btn: Button = $Margin/Panel/InnerMargin/VBox/Buttons/MenuButton

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
• Conservación Promedio de las 5 Parcelas: %.1f%%
• Fondo Familiar Acumulado: $%d
• Infractores Furtivos Detenidos en Garita: %d
• Errores Cometidos en Puesto de Control: %d
═══════════════════════════════════════════════════════""" % [
			avg_health,
			int(GameManager.family_savings),
			GameManager.total_infractors_stopped,
			GameManager.total_mistakes_made
		]

func _on_retry_pressed() -> void:
	SoundManager.play_sound("click")
	GameManager.play_prologue()

func _on_menu_pressed() -> void:
	SoundManager.play_sound("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
