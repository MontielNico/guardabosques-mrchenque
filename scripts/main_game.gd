extends Control
class_name MainGame

# Controlador Principal del Puesto de Control en Chalet Huergo

const PatagoniaView = preload("res://scripts/patagonia_view.gd")
const DocumentView = preload("res://scripts/document_view.gd")
const CarInspectionModal = preload("res://scripts/car_inspection.gd")
const RulebookModal = preload("res://scripts/rulebook_modal.gd")
const RadioAlertModal = preload("res://scripts/radio_alert_modal.gd")
const DataDB = preload("res://scripts/data_db.gd")

@onready var patagonia_view: PatagoniaView = $VBox/TopView/PatagoniaView
@onready var day_badge: Label = $VBox/TopView/TopHUD/DayBadge
@onready var visitor_counter_lbl: Label = $VBox/TopView/TopHUD/VisitorCounter
@onready var funds_badge: Label = $VBox/TopView/TopHUD/FundsBadge
@onready var radio_btn: Button = $VBox/TopView/TopHUD/RadioAlertBtn

# Mostrador / Desk Controls
@onready var fire_badge_desk: Label = $VBox/DeskView/Margin/HBox/LeftDesk/VBox/ClimateBox/FireBadge
@onready var weather_desc_desk: Label = $VBox/DeskView/Margin/HBox/LeftDesk/VBox/ClimateBox/WeatherLabel
@onready var fauna_desk: Label = $VBox/DeskView/Margin/HBox/LeftDesk/VBox/FaunaBox/FaunaLabel
@onready var rulebook_btn: Button = $VBox/DeskView/Margin/HBox/LeftDesk/VBox/RulebookBtn
@onready var inspect_car_btn: Button = $VBox/DeskView/Margin/HBox/LeftDesk/VBox/InspectCarBtn

# Centro: Diálogo y Documento
@onready var visitor_name_lbl: Label = $VBox/DeskView/Margin/HBox/CenterDesk/VBox/DialogBox/HBox/VBox/VisitorName
@onready var dialog_text: Label = $VBox/DeskView/Margin/HBox/CenterDesk/VBox/DialogBox/HBox/VBox/DialogText
@onready var interrogate_btn: Button = $VBox/DeskView/Margin/HBox/CenterDesk/VBox/DialogBox/HBox/InterrogateBtn
@onready var document_view: DocumentView = $VBox/DeskView/Margin/HBox/CenterDesk/VBox/DocumentView

# Derecha: Sellos de Decisión
@onready var approve_btn: Button = $VBox/DeskView/Margin/HBox/RightDesk/VBox/DecisionsBox/ApproveBtn
@onready var reject_btn: Button = $VBox/DeskView/Margin/HBox/RightDesk/VBox/DecisionsBox/RejectBtn
@onready var feedback_lbl: Label = $VBox/DeskView/Margin/HBox/RightDesk/VBox/FeedbackLabel

# Modales
@onready var car_inspection_modal: CarInspectionModal = $Modals/CarInspectionModal
@onready var rulebook_modal: RulebookModal = $Modals/RulebookModal
@onready var radio_alert_modal: RadioAlertModal = $Modals/RadioAlertModal

var day_info: Dictionary = {}
var visitors_today: Array[Dictionary] = []
var current_visitor_idx: int = 0
var current_visitor: Dictionary = {}
var is_processing_decision: bool = false
var pending_event: Dictionary = {}

func _ready() -> void:
	# Conectar botones
	if approve_btn:
		approve_btn.pressed.connect(_on_approve_pressed)
	if reject_btn:
		reject_btn.pressed.connect(_on_reject_pressed)
	if inspect_car_btn:
		inspect_car_btn.pressed.connect(_on_inspect_car_pressed)
	if rulebook_btn:
		rulebook_btn.pressed.connect(_on_rulebook_pressed)
	if interrogate_btn:
		interrogate_btn.pressed.connect(_on_interrogate_pressed)
	if radio_btn:
		radio_btn.pressed.connect(_on_radio_btn_pressed)
	if radio_alert_modal:
		radio_alert_modal.intervention_chosen.connect(_on_intervention_resolved)
		
	start_day(GameManager.current_day)

func start_day(day_num: int) -> void:
	day_info = DataDB.get_day_info(day_num)
	visitors_today = DataDB.get_visitors_for_day(day_num)
	current_visitor_idx = 0
	is_processing_decision = false
	pending_event.clear()
	
	if day_badge:
		day_badge.text = "DÍA %d / %d: %s" % [day_num, GameManager.MAX_DAYS, day_info.get("season", "")]
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % GameManager.family_savings
	if fire_badge_desk:
		var risk = day_info.get("fire_risk", "MEDIO")
		fire_badge_desk.text = "🔥 RIESGO INCENDIO: " + risk
		fire_badge_desk.modulate = day_info.get("fire_risk_color", Color.YELLOW)
	if weather_desc_desk:
		weather_desc_desk.text = day_info.get("weather", "")
	if fauna_desk:
		fauna_desk.text = "Fauna: " + day_info.get("protected_fauna", "")
	if radio_btn:
		radio_btn.visible = false
		
	_load_visitor(current_visitor_idx)

func _load_visitor(idx: int) -> void:
	if idx >= visitors_today.size():
		# Terminaron los visitantes de hoy
		_end_day()
		return
		
	current_visitor = visitors_today[idx]
	is_processing_decision = false
	
	if visitor_counter_lbl:
		visitor_counter_lbl.text = "VEHÍCULO %d DE %d" % [idx + 1, visitors_today.size()]
	if feedback_lbl:
		feedback_lbl.text = ""
		
	# Actualizar vista exterior
	if patagonia_view:
		patagonia_view.set_visitor(current_visitor)
	SoundManager.play_sound("car_engine")
	
	# Actualizar diálogo
	if visitor_name_lbl:
		visitor_name_lbl.text = current_visitor.get("name", "Visitante") + " (" + current_visitor.get("car_name", "") + ")"
	if dialog_text:
		dialog_text.text = '"' + current_visitor.get("dialog_intro", "Buenas tardes oficial.") + '"'
		
	# Cargar documento en mostrador
	if document_view:
		var doc_data = current_visitor.get("doc", {})
		document_view.load_document(doc_data)
		
	_enable_decision_buttons(true)
	
	# Verificar si se dispara alerta de radio en este visitante
	_check_day_events(idx)

func _check_day_events(visitor_idx: int) -> void:
	var events = day_info.get("events", [])
	for ev in events:
		if ev.get("trigger_at_visitor", -1) == visitor_idx:
			pending_event = ev
			if radio_btn:
				radio_btn.visible = true
				radio_btn.text = "🚨 ¡EMERGENCIA RADIAL EN PARCELA!"
				radio_btn.modulate = Color(1.0, 0.2, 0.2)
			SoundManager.play_sound("radio")
			break

func _on_radio_btn_pressed() -> void:
	if not pending_event.is_empty():
		radio_alert_modal.show_alert(pending_event)

func _on_intervention_resolved(went_to_patrol: bool) -> void:
	var result = GameManager.resolve_patrol_event(pending_event, went_to_patrol)
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % GameManager.family_savings
	if feedback_lbl:
		feedback_lbl.text = result.get("message", "")
		feedback_lbl.modulate = Color(0.3, 1.0, 0.5) if went_to_patrol else Color(1.0, 0.5, 0.3)
	if radio_btn:
		radio_btn.visible = false
	pending_event.clear()

func _on_approve_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(true)

func _on_reject_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(false)

func _make_decision(approved: bool) -> void:
	is_processing_decision = true
	_enable_decision_buttons(false)
	
	if document_view:
		document_view.apply_stamp(approved)
		
	var decision_result = GameManager.record_decision(current_visitor, approved)
	
	if approved:
		if patagonia_view:
			patagonia_view.open_barrier_and_pass()
		if dialog_text:
			dialog_text.text = '"Muchas gracias oficial, que tenga buen día."'
	else:
		if patagonia_view:
			patagonia_view.reject_and_turn_back()
		if dialog_text:
			dialog_text.text = '"¡Qué barbaridad! Me quejaré a la municipalidad..."'
			
	if feedback_lbl:
		if decision_result.get("status") == "CORRECTO":
			feedback_lbl.text = "✔ DECISIÓN CORRECTA"
			feedback_lbl.modulate = Color(0.2, 0.9, 0.3)
		else:
			feedback_lbl.text = "✖ ERROR EN REVISIÓN (Multa aplicada)"
			feedback_lbl.modulate = Color(0.95, 0.2, 0.2)

	# Esperar 2 segundos antes del siguiente auto
	await get_tree().create_timer(2.2).timeout
	current_visitor_idx += 1
	_load_visitor(current_visitor_idx)

func _enable_decision_buttons(enabled: bool) -> void:
	if approve_btn:
		approve_btn.disabled = not enabled
	if reject_btn:
		reject_btn.disabled = not enabled

func _on_inspect_car_pressed() -> void:
	if car_inspection_modal:
		car_inspection_modal.open_inspection(current_visitor)

func _on_rulebook_pressed() -> void:
	if rulebook_modal:
		rulebook_modal.open_rulebook(day_info)

func _on_interrogate_pressed() -> void:
	SoundManager.play_sound("paper")
	if dialog_text and not current_visitor.is_empty():
		dialog_text.text = '"' + current_visitor.get("dialog_interrogate", "No tengo nada que ocultar.") + '"'

func _end_day() -> void:
	var summary = GameManager.finish_current_day()
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")
