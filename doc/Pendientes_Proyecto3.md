# Pendientes del Proyecto 3

Estado al **24 nov 2026**. Entrega: **viernes 4 de diciembre**. Basado en el código ya escrito (`proyecto3.zip`) y en la guía de montaje (`Guia_Montaje_Proyecto3.md`).
Responsables según el reparto: **A** = Ariel (hardware, lectura, FSM), **J** = Josué (datapath, display, top, simulaciones, diagramas).

## Lo que ya está hecho

- Código completo: `teclado_top`, `lectura_teclas`, `fsm_vending`, `datapath_vending`, `temporizador_devolucion`, `vending_core`, `top`, más los módulos reutilizados del P2 y los del profesor.
- Testbenches que pasan (RTL): `fsm_vending_tb`, `vending_core_tb` (los 4 casos obligatorios), `lectura_teclas_tb`, `display_subsystem_tb`.
- Síntesis con Yosys sin errores ni latches (`top`, `top_prueba_teclado`, `top_prueba_display`).
- `.cst` con los pines finales del P2 más los LEDs, `interfaces.md`, estándar de código, README, guía de montaje.

---

## 1. Urgente (esta semana)

| # | Pendiente | Quién | Notas |
|---|---|---|---|
| 1 | Subir el esqueleto a GitHub y dar acceso a ambos | J | Comandos en el mensaje anterior. `make synth` desde `src/build` para confirmar el entorno |
| 2 | Montar el hardware según la guía (displays → teclado → LED externo) | A | Probar cada paso: `top_prueba_display`, `top_prueba_teclado`, luego `make all` |
| 3 | Comprobar la serigrafía de los LEDs internos (LED0 = pin 10 … LED5 = pin 16) | A | Si no coincide, ajustar el `.cst` |
| 4 | **Place and route** del `top` completo (`make pnr`) y revisar frecuencia ≥ 27 MHz | J | No se ha podido correr en el sandbox; el P2 dio ~37 MHz |
| 5 | Prueba en placa con la tabla de la sección 7 de la guía (10 filas) | A + J | Anotar resultados para la bitácora |
| 6 | Diagrama de estados, tabla de transiciones y ecuaciones de la FSM | A + J | Partir de `Proyecto3_FSM_Borrador.md` y del comentario de `fsm_vending.sv`. Es lo que preguntan en el oral |

## 2. Código por escribir

| # | Pendiente | Quién | Prioridad |
|---|---|---|---|
| 7 | `datapath_vending_tb`: probar el datapath solo (precios, crédito = monedas × 100, signo de la resta, inventario). Hoy solo se prueba dentro de `vending_core_tb` | J | Alta (el enunciado pide simular cada subsistema) |
| 8 | Objetivos en el Makefile para **simulación post-síntesis y post-place-and-route** (netlist + `cells_sim.v`, como en el P2) | J | Alta |
| 9 | `top_tb`: testbench del sistema completo con teclado (usar `defparam` para acortar el DeBounce, como en el P2) | J | Media |
| 10 | **Display extra (25 %):** código de producto, monedas y vuelto según el estado de la FSM. Hay que definir el protocolo del grupo | J (diseño con A) | Baja: recortar si el tiempo aprieta |
| 11 | Si el teclado vuelve a fallar en placa: `top_diag_teclado` (existe del P2, en `cambios_repo6`) | A | Solo si hace falta |

## 3. Simulaciones por subsistema (entregable)

El enunciado pide RTL, post-síntesis y post-PnR **por subsistema**. Tabla mínima:

| Subsistema | RTL | Post-síntesis | Post-PnR |
|---|---|---|---|
| 4.1 Lectura (`lectura_teclas`; `teclado_top` con DeBounce acortado) | ✔ | ☐ | ☐ |
| 4.2 FSM (`fsm_vending_tb`) | ✔ | ☐ | ☐ |
| 4.3 Aritmética (`datapath_vending_tb`) | ☐ | ☐ | ☐ |
| 4.4 Display (`display_subsystem_tb`) | ✔ | ☐ | ☐ |
| Sistema (`vending_core_tb`, los 4 casos) | ✔ | ☐ | ☐ |

Guardar capturas de GTKWave de cada una en `doc/mediciones/`. **Pregunta pendiente al profesor:** cómo espera la simulación post-PnR (el flujo abierto no la genera directamente).

## 4. Documentación

| # | Pendiente | Quién |
|---|---|---|
| 12 | Diagramas por subsistema (4.1 a 4.4) y plan general del sistema, en `doc/diagramas/` | J (FSM con A) |
| 13 | **Bitácora individual a mano**, con firma semanal del asistente. Incluir la justificación del ancho de 11 bits (`crédito − precio` va de −400 a +750) | A y J, cada uno la suya |
| 14 | Completar `referencias.md` y el `README.md` final | J |
| 15 | Verificar el formato de entrega en el PDF del enunciado (repo, zip, fecha y hora) | J |

## 5. Preparación del oral (FSM)

Ambos deben poder explicar sin ayuda:
- Por qué One-Hot y cuáles son los 7 estados.
- Por qué existen `CALCULO` y `EVALUA` por separado (la resta está registrada y el signo vale un ciclo después).
- Por qué las salidas son Moore y qué significa que cada una sea un bit de estado.
- Cómo se decide "alcanza el crédito": con el signo de la resta, sin comparador.
- Qué hace el reset (restaura inventario) frente a RESTART (no lo borra).
- Recorrer en el diagrama los 4 casos: pago exacto, sobrepago, pago insuficiente y producto agotado.

## 6. Cronograma propuesto (hasta el 4 dic)

| Día | Trabajo |
|---|---|
| Mar 24 – Mié 25 | Repo en GitHub, montaje y pruebas del display y del teclado (A); `datapath_vending_tb` y objetivos del Makefile (J); diagrama de la FSM entre ambos |
| Jue 26 | PnR y `make all` del `top`; primera prueba completa en placa |
| Vie 27 – Sáb 28 | Pruebas de la sección 7 de la guía; simulaciones post-síntesis y post-PnR |
| Dom 29 – Lun 30 | Diagramas, `top_tb`, bitácoras; display extra solo si todo lo anterior está listo |
| Mar 1 – Jue 3 dic | Colchón (semana de finales): correcciones, repaso del oral, revisar el entregable |
| **Vie 4 dic** | **Entrega** |

**Si el tiempo aprieta, recorten en este orden:** display extra → `top_tb` completo → temporizador de devolución (dejarlo en 1 ciclo) → pulido de diagramas. Lo que **no** se recorta: los 4 casos en simulación y en placa, el diagrama de la FSM y la bitácora.

## 7. Decisiones ya tomadas (para no reabrirlas)

- Teclado: A, B, C = producto; 0–9 = monedas (queda la última); D = START; `*` = RESTART; `#` sin función.
- Comentarios siempre en español, incluso en la FSM. Se ignoran las indicaciones del enunciado que no tienen sentido (por ejemplo, no conectar el bloque del display).
- Salidas de la FSM tipo Moore; `restart` solo sale de `ENTREGADO` (en `DEVOLUCION` se espera al temporizador de ~2 s).
- Después de una compra la selección queda guardada: D repite la misma compra hasta presionar `*`.
