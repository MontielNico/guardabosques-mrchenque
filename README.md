# 🌲 Guarda-Bosques: Patagonia (Parque Chalet Huergo)

Prototipo de videojuego 2D estilo **Papers, Please** desarrollado en **Godot Engine 4** ambientado en el histórico **Chalet Huergo** y el **Cerro Chenque** (Comodoro Rivadavia, Chubut, Patagonia Argentina).

---

## 🎮 Contexto y Jugabilidad
Encarnas a **Mr. Chenque**, el guardaparques responsable del puesto de control durante **5 días consecutivos**.

### Dinámica de Juego:
1. **Inspección de Visitantes:**
   - Observa el vehículo y el visitante que llega al puesto de control.
   - Lee su diálogo y aclara inconsistencias.
   - Haz clic en **🔍 INSPECCIONAR VEHÍCULO** para revisar el baúl, los asientos y contar los pasajeros reales a bordo.
2. **Revisión Documental:**
   - Lee el **Pase de Ingreso / Permiso** en el mostrador (Titular, DNI, fecha de validez, personas autorizadas, permisos especiales de fuego y pesca).
3. **Condiciones del Día:**
   - Revisa el **Riesgo de Incendio**, viento y fauna protegida:
     - *Riesgo Medio:* Fuego solo con Permiso de Fuego explícito.
     - *Riesgo Alto / Extremo:* Prohibición total de carbón, leña, bidones de combustible y motosierras.
     - *Prohibición estricta de caza:* Armas, rifles, trampas y usurpación de tierras son motivo de rechazo inmediato.
4. **Toma de Decisiones:**
   - 🟢 **AUTORIZAR (Sello Verde):** Abre la barrera y deja entrar al vehículo al parque.
   - 🔴 **DENEGAR (Sello Rojo):** Rechaza el acceso y el auto da media vuelta.
5. **Emergencias Radiales y Patrullaje:**
   - Cuando suene la **Radio de Emergencia**, decide si intervenir una parcela (ganando un bonus económico y previniendo incendios o usurpaciones) o quedarte en la garita.
6. **Finanzas Familiares y Estado del Parque:**
   - Al final de cada día se liquida el sueldo, se pagan los gastos del hogar familiar (calefacción a gas patagónico, alimentos, medicinas) y se muestra el estado de salud de las 4 parcelas del parque:
     * *Chalet Histórico*
     * *Bosque de Lengas y Pinos*
     * *Costa y Pingüinera*
     * *Cerro Chenque y Acantilados*
7. **Evaluación Final (Día 5):**
   - 4 finales posibles según la conservación del parque y los ahorros acumulados.

---

## 🚀 Cómo Ejecutar el Juego

### Opción 1: Desde Godot Editor
1. Abre **Godot Engine 4** (`Godot_v4.7.2-stable_win64.exe`).
2. En el Administrador de Proyectos, haz clic en **Importar** y selecciona el archivo `project.godot` dentro de la carpeta `Documents/guarda-bosques-patagonia`.
3. Presiona **F5** o el botón de Play ▶️ arriba a la derecha.

### Opción 2: Desde la Terminal / PowerShell
```powershell
& "C:\Users\bruno\Desktop\Godot_v4.7.2-stable_win64_console.exe" --path "C:\Users\bruno\Documents\guarda-bosques-patagonia"
```
