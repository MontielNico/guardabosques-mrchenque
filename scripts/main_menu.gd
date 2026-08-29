extends Control
class_name MainMenu

# Menú Principal del Juego - Guarda-Bosques: Parque Chalet Huergo

@onready var start_btn: Button = $Panel/Margin/VBox/Buttons/StartButton
@onready var manual_btn: Button = $Panel/Margin/VBox/Buttons/ManualButton
@onready var credits_btn: Button = $Panel/Margin/VBox/Buttons/CreditsButton
@onready var manual_dialog: AcceptDialog = $ManualDialog
@onready var credits_dialog: AcceptDialog = $CreditsDialog

func _ready() -> void:
	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
	if manual_btn:
		manual_btn.pressed.connect(_on_manual_pressed)
	if credits_btn:
		credits_btn.pressed.connect(_on_credits_pressed)

func _on_start_pressed() -> void:
	SoundManager.play_sound("click")
	GameManager.play_prologue()

func _on_manual_pressed() -> void:
	SoundManager.play_sound("paper")
	if manual_dialog:
		manual_dialog.popup_centered()

func _on_credits_pressed() -> void:
	SoundManager.play_sound("click")
	if credits_dialog:
		credits_dialog.popup_centered()
