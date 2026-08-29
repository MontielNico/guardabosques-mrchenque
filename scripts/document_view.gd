extends PanelContainer
class_name DocumentView

# Visualización e Interacción de los Documentos del Visitante (Ventana 4: Escritorio)

@onready var doc_title: Label = $Margin/VBox/Header/DocTitle
@onready var name_val: Label = $Margin/VBox/Grid/NameVal
@onready var dni_val: Label = $Margin/VBox/Grid/DniVal
@onready var date_val: Label = $Margin/VBox/Grid/DateVal
@onready var purpose_val: Label = $Margin/VBox/Grid/PurposeVal
@onready var people_val: Label = $Margin/VBox/Grid/PeopleVal
@onready var job_permit_val: Label = $Margin/VBox/Grid/JobPermitVal

@onready var fire_permit_val: Label = $Margin/VBox/PermitsBox/FirePermitVal
@onready var fishing_permit_val: Label = $Margin/VBox/PermitsBox/FishingPermitVal
@onready var stamp_visual: Label = $StampVisual

var is_stamped: bool = false

func _ready() -> void:
	if stamp_visual:
		stamp_visual.visible = false

func load_document(doc_data: Dictionary) -> void:
	is_stamped = false
	if stamp_visual:
		stamp_visual.visible = false
	
	if doc_title:
		doc_title.text = "🏛️ " + doc_data.get("type", "Pase de Ingreso Diario").to_upper()
	if name_val:
		name_val.text = doc_data.get("name", "Desconocido")
	if dni_val:
		dni_val.text = doc_data.get("dni", "00.000.000")
	if date_val:
		var dt = doc_data.get("date", "28/11/2026")
		var expired = doc_data.get("is_expired", false)
		if expired:
			date_val.text = dt + " (⚠️ VENCIDO)"
			date_val.modulate = Color(1.0, 0.25, 0.25)
		else:
			date_val.text = dt + " (Vigente)"
			date_val.modulate = Color(0.15, 0.65, 0.2)
	if purpose_val:
		purpose_val.text = doc_data.get("purpose", "Paseo")
	if people_val:
		people_val.text = str(doc_data.get("passengers", 1)) + " personas autorizadas"
	if job_permit_val:
		var job = doc_data.get("job_permit", "Ninguno (Particular)")
		job_permit_val.text = job
		if "Ninguno" in job:
			job_permit_val.modulate = Color(0.4, 0.35, 0.3)
		else:
			job_permit_val.modulate = Color(0.1, 0.4, 0.7)
		
	if fire_permit_val:
		var has_fire = doc_data.get("fire_permit", false)
		fire_permit_val.text = "HABILITADO ✔️" if has_fire else "NO AUTORIZADO ❌"
		fire_permit_val.modulate = Color(0.15, 0.65, 0.2) if has_fire else Color(0.85, 0.2, 0.2)
		
	if fishing_permit_val:
		var has_fishing = doc_data.get("fishing_permit", false)
		fishing_permit_val.text = "HABILITADO ✔️" if has_fishing else "NO AUTORIZADO ❌"
		fishing_permit_val.modulate = Color(0.15, 0.65, 0.2) if has_fishing else Color(0.85, 0.2, 0.2)

func apply_stamp(approved: bool) -> void:
	is_stamped = true
	if stamp_visual:
		stamp_visual.visible = true
		if approved:
			stamp_visual.text = "【 AUTORIZADO 】\nPARQUE NACIONAL CHALET HUERGO"
			stamp_visual.modulate = Color(0.1, 0.7, 0.2, 0.9)
			stamp_visual.rotation = -0.1
			SoundManager.play_sound("stamp_approve")
		else:
			stamp_visual.text = "【 DENEGADO 】\nACCESO RECHAZADO POR PROTOCOLO"
			stamp_visual.modulate = Color(0.85, 0.12, 0.12, 0.9)
			stamp_visual.rotation = 0.12
			SoundManager.play_sound("stamp_reject")
