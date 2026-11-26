# Pendientes del Proyecto 3

Estado al **25 nov 2026**. Entrega: **viernes 4 de diciembre**. **A** = Ariel, **J** = Josué.

## Lo que ya está hecho

- **Código completo**, incluido el display extra (25 %): lectura (`teclado_top`, `lectura_teclas`), FSM One-Hot, datapath, temporizador, `vending_core`, `display_vending_src` + `display_4hex`, `top`.
- **Testbenches RTL que pasan:** `lectura_teclas_tb`, `fsm_vending_tb`, `datapath_vending_tb`, `display_vending_tb`, `display_subsystem_tb`, `vending_core_tb` (los 4 casos del enunciado) y `top_tb` (los 4 casos con teclas simuladas).
- **Post-síntesis:** `make postall` corre la simulación de netlist de los 5 subsistemas y todas pasan.
- **Síntesis y place and route del `top` completo:** 0 problemas, Fmax ≈ 59 MHz (el reloj es 27 MHz).
- Circuito montado y funcionando en la placa (según Ariel).

## 1. Esta semana: pruebas en la placa

| # | Pendiente | Quién |
|---|---|---|
| 1 | Cargar el diseño final (`make all`) y correr la tabla de pruebas de la sección 7 de la guía de montaje (12 filas). Anotar resultado de cada una | A + J |
| 2 | Verificar el orden de los 6 LEDs internos (LED0–LED2 = entrega A, B, C; LED3–LED5 = agotado A, B, C) | A |
| 3 | Verificar el display extra: letras `A`, `b`, `C`, `d` legibles y dígitos apagados donde corresponde | A |
| 4 | Si algo falla: anotar el síntoma exacto (teclas, LED, display) y pasármelo | A |

## 2. Simulaciones por subsistema (entregable)

| Subsistema | RTL | Post-síntesis | Post-PnR |
|---|---|---|---|
| 4.1 Lectura (`lectura_teclas`) | ✔ | ✔ | ☐ |
| 4.2 FSM (`fsm_vending_tb`) | ✔ | ✔ | ☐ |
| 4.3 Aritmética (`datapath_vending_tb`) | ✔ | ✔ | ☐ |
| 4.4 Display (`display_vending_tb`, `display_subsystem_tb`) | ✔ | ✔ (`display_vending_src`) | ☐ |
| Sistema (`vending_core_tb`, `top_tb`) | ✔ | ✔ (`vending_core`) | ☐ |

| # | Pendiente | Quién |
|---|---|---|
| 5 | Correr `make postall` en su máquina (si `yosys-config` falla en Windows: `make postall CELLS_SIM=<ruta>/gowin/cells_sim.v`) y guardar capturas de GTKWave en `doc/mediciones/` | J |
| 6 | **Post-place-and-route: preguntar al profesor qué acepta.** El `nextpnr` abierto no genera una netlist simulable (sus celdas físicas SLICE e IOB no tienen modelo y los pines no quedan conectados a los puertos). Evidencia que sí hay: `pnr_tangnano9k.log` (uso de recursos, Fmax 59 MHz, pines del `.cst`). Si el profesor exige simulación, la alternativa es desempacar el bitstream con `gowin_unpack` y simular esa netlist; es posible pero laborioso, y lo armamos solo si lo piden | J |

## 3. Documentación

| # | Pendiente | Quién |
|---|---|---|
| 7 | Diagrama de estados, tabla de transiciones y ecuaciones de la FSM (partir de `Proyecto3_FSM_Borrador.md` y del encabezado de `fsm_vending.sv`) | A + J |
| 8 | Diagramas por subsistema (4.1 a 4.4), diagrama del sistema completo y plan general, en `doc/diagramas/` | J |
| 9 | **Bitácora individual a mano**, firmada semanalmente. Incluir la justificación del ancho de 11 bits (`crédito − precio` va de −400 a +750) y el protocolo del display extra | A y J |
| 10 | Completar `referencias.md`; revisar `README.md` | J |
| 11 | Verificar el formato de entrega en el PDF del enunciado (repo, zip, fecha y hora) | J |
| 12 | Subir los cambios nuevos al repo (zip adjunto) y revisar que `make test`, `make synth` y `make postall` corran desde cero | J |

## 4. Preparación del oral (FSM)

Ambos deben poder explicar sin ayuda:
- Por qué One-Hot y cuáles son los 7 estados.
- Por qué `CALCULO` y `EVALUA` son estados separados (la resta está registrada y el signo vale un ciclo después).
- Por qué las salidas son Moore.
- Cómo se decide "alcanza el crédito": con el signo de la resta, sin comparador.
- Reset (restaura inventario) frente a RESTART (no lo borra).
- Recorrer en el diagrama los 4 casos: pago exacto, sobrepago, pago insuficiente y producto agotado.

## 5. Cronograma (hasta el 4 dic)

| Día | Trabajo |
|---|---|
| Jue 26 | Cargar el diseño final y correr la tabla de pruebas; corregir lo que falle |
| Vie 27 – Sáb 28 | `make postall` y capturas; diagrama de la FSM |
| Dom 29 – Lun 30 | Diagramas restantes, bitácoras, pregunta al profesor sobre post-PnR |
| Mar 1 – Jue 3 dic | Colchón (finales): repaso del oral y del entregable |
| **Vie 4 dic** | **Entrega** |

## 6. Decisiones ya tomadas

- Teclado: A, B, C = producto; 0–9 = monedas (queda la última); D = START; `*` = RESTART; `#` sin función.
- Comentarios siempre en español, incluso en la FSM. Se ignoran las indicaciones del enunciado que no tienen sentido.
- Salidas de la FSM tipo Moore; `restart` solo sale de `ENTREGADO` (en `DEVOLUCION` se espera el temporizador de ~2 s).
- Después de una compra la selección queda guardada: D repite la misma compra hasta presionar `*`.
- Display extra: producto a la izquierda; en reposo muestra monedas, en entrega el vuelto y en devolución `d` y las monedas.
