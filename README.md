# Proyecto Corto 3 — Máquina expendedora en Tang Nano 9K

EL-3307 Diseño Lógico, II Semestre 2026, TEC. Integrantes: Josué Sanabria, Ariel Elizondo. **Entrega: viernes 4 de diciembre de 2026.**

Tres productos (A ₡150, B ₡275, C ₡400), 3 unidades de cada uno, monedas de ₡100. FSM One-Hot que valida el pago, entrega o devuelve las monedas y muestra el vuelto en 4 displays de 7 segmentos.

## Estructura

```
doc/          interfaces.md (contrato entre módulos), estandar_de_codigo.md, diagramas/, mediciones/, bitacora/, originales_profe/
src/design/   código sintetizable (todos los .sv; el Makefile los toma todos). profesor/ = código del profesor sin modificar
src/sim/      testbenches: <módulo>_tb.sv
src/constr/   proyecto3.cst (pines)
src/build/    Makefile y bcdtable.txt
```

## Módulos y responsables

| Módulo | Subsistema | Estado |
|---|---|---|
| `sincronizar_filas`, `tk_columnas`, `avance_columnas`, `deco_teclado` | 4.1 lectura | reutilizados del P2 |
| `teclado_top` (cableado + DeBounce del profesor) | 4.1 lectura | listo, probar en placa |
| `lectura_teclas` (PROD_SEL, IN_COINS, start, restart) | 4.1 lectura | listo + testbench |
| `fsm_vending` | 4.2 FSM One-Hot | listo + testbench |
| `datapath_vending` | 4.3 aritmética | listo (probado vía `vending_core_tb`) |
| `temporizador_devolucion` | devolución ~2 s | listo |
| `vending_core` (FSM + datapath + timer) | sistema | listo + testbench con los 4 casos |
| `display_subsystem` | 4.4 display | reutilizado del P2 |
| `top` | integración | listo (`led_devuelve` en el pin 26) |

Reparto de trabajo: ver `Proyecto3_Decisiones_y_Reparto.md`.

## Comandos (desde `src/build`)

```
make test TB=fsm_vending_tb     # simulación RTL con iverilog
make wv TB=fsm_vending_tb       # ver ondas en GTKWave
make synth                      # síntesis (revisar synthesis_tangnano9k.log)
make all                        # síntesis + PnR + bitstream + carga a la placa
```

## Flujo de trabajo con git

- `main` solo recibe código que simula y sintetiza.
- Una rama por persona/tarea (`ariel/lectura`, `josue/datapath`...) y *pull request* revisado por la otra persona.
- Antes de cambiar una señal entre módulos: actualizar `doc/interfaces.md`.

## Referencias

Ver `doc/referencias.md` (agregar todo lo que no sea propio).
