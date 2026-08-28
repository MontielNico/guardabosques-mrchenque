extends PanelContainer
class_name RadioAlertModal

# Modal de Alerta Radial / Intervención de Parcelas en Chalet Huergo

signal intervention_chosen(went_to_patrol: bool)

@onready var alert_title: Label = $Margin/VBox/AlertTitle
@onready var alert_desc: Label = $Margin/VBox/AlertDesc
@onready var parcel_info: Label = $Margin/VBox/ParcelInfo
@onready var reward_info: Label = $Margin/VBox/RewardInfo
@onready var patrol_btn: Button = $Margin/VBox/Buttons/PatrolButton
@onready var stay_btn: Button = $Margin/VBox/Buttons/StayButton

var current_event: Dictionary = {}

func _ready() -> void:
	if patrol_btn:
		patrol_btn.pressed.connect(_on_patrol_pressed)
	if stay_btn:
		stay_btn.pressed.connect(_on_stay_pressed)

func show_alert(event_data: Dictionary) -> void:
	current_event = event_data
	visible = true
	SoundManager.play_sound("radio")
	SoundManager.play_sound("alarm")
	
	if alert_title:
		alert_title.text = event_data.get("title", "¡ALERTA RADIAL URGENTE!")
	if alert_desc:
		alert_desc.text = event_data.get("description", "")
	if parcel_info:
		parcel_info.text = "Sector Afectado: " + event_data.get("parcel", "Parque")
	if reward_info:
		var rew = event_data.get("reward", 15000)
		var dmg = event_data.get("damage_if_ignored", 30)
		reward_info.text = "Bonus por intervención exitosa: +$%d  |  Riesgo ecológico si se ignora: -%d%% salud" % [rew, dmg]

func _on_patrol_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	intervention_chosen.emit(true)

func _on_stay_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	intervention_chosen.emit(false)
