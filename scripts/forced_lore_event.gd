extends Resource
class_name ForcedLoreEvent

## ForcedLoreEvent
## Ata un VisitorProfile específico a una posición EXACTA de la cola del día.
## No compite contra el pool ponderado: se inserta sí o sí, tenga o no
## sentido con el pity system (el spawner prioriza absolutamente esto).

@export var spawn_index: int = 0
@export var visitor: VisitorProfile
