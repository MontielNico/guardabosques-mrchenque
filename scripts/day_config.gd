extends Resource
class_name DayConfig

## DayConfig
## Toda la configuración de un día de juego: cuántos visitantes, qué tiers
## están habilitados y con qué peso, y qué eventos de lore son obligatorios.

@export var day_number: int = 1
@export var total_visitors: int = 8

@export_group("Ambientación (reemplaza a DataDB.get_day_info)")
@export var day_title: String = "" # Ej: "Boletín Diario - Día 1"
@export var season_label: String = "" # Ej: "Verano austral"
@export var weather_description: String = "" # Ej: "Viento fuerte del oeste, 8°C"
@export var fire_risk_label: String = "MEDIO" # BAJO / MEDIO / ALTO
@export var fire_risk_color: Color = Color.YELLOW
@export var protected_fauna_note: String = "" # Ej: "Pingüinos anidando en Costa Sur"
@export var rules_summary: Array[String] = []

@export_group("Pools ponderados por Tier")
@export var simple_pool: Array[VisitorProfile] = []
@export var medium_pool: Array[VisitorProfile] = []
@export var complex_pool: Array[VisitorProfile] = []

@export_group("Peso de selección por Tier (0.0 a 1.0)")
## Día 1 ejemplo: weight_simple = 1.0, resto en 0 -> solo Simple.
## Día 2 ejemplo: weight_simple = 0.6, weight_medium = 0.4 -> introduce Medium.
@export_range(0.0, 1.0, 0.05) var weight_simple: float = 1.0
@export_range(0.0, 1.0, 0.05) var weight_medium: float = 0.0
@export_range(0.0, 1.0, 0.05) var weight_complex: float = 0.0

@export_group("Narrativa")
@export var forced_lore_events: Array[ForcedLoreEvent] = []

## NUEVO: Inyección determinista de OBJETOS de lore (distinto de
## forced_lore_events, que inyecta visitantes ENTEROS). Estos strings van a
## parar, garantizado, al hidden_items de algún visitante random del día
## (ver VisitorSpawner._inject_forced_hidden_items), sin necesidad de crear
## un VisitorProfile dedicado para cada objeto. Caso de uso: Día 4, "Foto de
## Mr. Chenque de 1920" y "Mapa de túneles del Chenque" apareciendo en
## baúles cualquiera del día.
@export var forced_hidden_items: Array[String] = []

## Cuántos Medium/Complex consecutivos se toleran antes de forzar un Simple.
@export var max_consecutive_hard: int = 2

# NUEVO: Flags ambientales por día. DayManager los lee en start_day() y los
# empaqueta en la señal `environment_flags_applied` para que la UI/Environment
# reaccionen (oscurecer pantalla, tintar el mar, etc.) sin acoplar DayManager
# a ningún nodo visual concreto.
@export_group("Efectos Ambientales (Matriz Narrativa)")
## Día 3: niebla costera. La UI debe oscurecer/desaturar al activarse.
@export var is_foggy: bool = false
## Día 4: marea alta anómala. Dispara variantes visuales en costa/mapa.
@export var high_tide_anomalies: bool = false

func get_tier_weights() -> Dictionary:
	return {
		VisitorProfile.VisitorTier.SIMPLE: weight_simple,
		VisitorProfile.VisitorTier.MEDIUM: weight_medium,
		VisitorProfile.VisitorTier.COMPLEX: weight_complex
	}

## NUEVO: empaqueta los flags ambientales del día en un Dictionary genérico,
## para que DayManager los pueda emitir por señal sin tener que ir agregando
## parámetros nuevos a la firma de la señal cada vez que se suma un efecto.
func get_environment_flags() -> Dictionary:
	return {
		"is_foggy": is_foggy,
		"high_tide_anomalies": high_tide_anomalies
	}

func get_forced_event_at(index: int) -> ForcedLoreEvent:
	for event in forced_lore_events:
		if event.spawn_index == index:
			return event
	return null

## Adaptador exacto para rulebook_modal.gd, que espera un Dictionary
## (antes venía de DataDB.get_day_info()).
func to_legacy_day_info_dict() -> Dictionary:
	return {
		"title": day_title,
		"weather": weather_description,
		"fire_risk": fire_risk_label,
		"fire_risk_color": fire_risk_color,
		"protected_fauna": protected_fauna_note,
		"rules_summary": rules_summary
	}
