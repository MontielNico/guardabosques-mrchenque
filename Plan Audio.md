# Plan Audio

## Audios Disponibles:

* **Jazz_Radio** (`res://public/audio/Jazz__Radio_.mp3`)
* **Investigation** (`res://public/audio/(Fast)_Investigation__Guardaparque_Game_Soundtrack_.mp3`)
* **Ambient** (`res://public/audio/Ambient _Guardaparque Game Soundtrack_.mp3`)

---

## Reglas de Reproducción y Transición:

1. **Ambient**:
   * Se reproduce en **todas las escenas** desde el `main_menu` hasta el final del día **martes** (`game_intro`, `day_intro` / `day_start_intro`, `main_game` y `day_summary` de Lunes y Martes).
   * Se mantiene sonando continuamente sin cortarse ni mutearse entre escenas.

2. **Investigation**:
   * Se activa a partir del día **miércoles** y se reproduce en **todas las escenas** (`day_start_intro`, `day_intro`, `main_game`, `day_summary` de Miércoles, Jueves y Viernes) hasta llegar a la escena de `game_over`.
   * Transición fluida (*cross-fade*) desde `Ambient` al comenzar el Miércoles.

3. **Jazz_Radio**:
   * Se reproduce en la escena `game_over` (Evaluación Final).
   * Realiza una transición de menos a más (*fade-in*) desde silencio (-80 dB) hasta el volumen adecuado.