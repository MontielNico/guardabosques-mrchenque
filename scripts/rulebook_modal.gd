extends PanelContainer
class_name RulebookModal

# Modal del Manual de Procedimientos y Boletín Diario de Normas

signal closed

@onready var day_title: Label = $Margin/VBox/Header/DayTitle
@onready var weather_label: Label = $Margin/VBox/Content/WeatherBox/WeatherLabel
@onready var fire_badge: Label = $Margin/VBox/Content/WeatherBox/FireBadge
@onready var fauna_label: Label = $Margin/VBox/Content/FaunaBox/FaunaLabel
@onready var rules_list: VBoxContainer = $Margin/VBox/Content/RulesScroll/RulesList
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

func open_rulebook(day_info: Dictionary) -> void:
	visible = true
	SoundManager.play_sound("paper")
	
	if day_title:
		day_title.text = day_info.get("title", "Boletín Diario de Parques")
	if weather_label:
		weather_label.text = "Clima: " + day_info.get("weather", "")
	if fire_badge:
		var risk = day_info.get("fire_risk", "MEDIO")
		fire_badge.text = "RIESGO DE INCENDIO: " + risk
		fire_badge.modulate = day_info.get("fire_risk_color", Color.YELLOW)
	if fauna_label:
		fauna_label.text = "Fauna y Zonas Sensibles: " + day_info.get("protected_fauna", "")
		
	# Llenar reglas
	for child in rules_list.get_children():
		child.queue_free()
		
	var rules = day_info.get("rules_summary", [])
	for r in rules:
		var r_lbl = Label.new()
		r_lbl.text = "• " + r
		r_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_lbl.add_theme_font_size_override("font_size", 14)
		rules_list.add_child(r_lbl)

func _on_close_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	closed.emit()
