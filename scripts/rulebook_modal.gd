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
	
	for child in rules_list.get_children():
		child.queue_free()
	
	var sections = day_info.get("cumulative_rule_sections", {})
	var visitors_rules = sections.get("visitors_and_documents", day_info.get("rules_summary", []))
	var error_rules = sections.get("error_logic", [])
	
	var title_visitor = Label.new()
	title_visitor.text = "VISITANTES Y DOCUMENTOS"
	title_visitor.add_theme_font_size_override("font_size", 15)
	title_visitor.modulate = Color(0.7, 0.9, 1.0)
	rules_list.add_child(title_visitor)
	for r in visitors_rules:
		var r_lbl = Label.new()
		r_lbl.text = "• " + r
		r_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_lbl.add_theme_font_size_override("font_size", 14)
		rules_list.add_child(r_lbl)
	
	var title_error = Label.new()
	title_error.text = "LÓGICA DE ERROR"
	title_error.add_theme_font_size_override("font_size", 15)
	title_error.modulate = Color(1.0, 0.7, 0.5)
	rules_list.add_child(title_error)
	if error_rules.is_empty():
		var no_error_lbl = Label.new()
		no_error_lbl.text = "• Sin reglas adicionales de error para este día."
		no_error_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		no_error_lbl.add_theme_font_size_override("font_size", 14)
		rules_list.add_child(no_error_lbl)
	else:
		for r in error_rules:
			var r_lbl = Label.new()
			r_lbl.text = "• " + r
			r_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			r_lbl.add_theme_font_size_override("font_size", 14)
			rules_list.add_child(r_lbl)

func _on_close_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	closed.emit()
