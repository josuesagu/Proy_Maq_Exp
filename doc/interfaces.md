# Interfaces entre módulos — Proyecto 3 (máquina expendedora)

Todo es síncrono al reloj `clk` de 27 MHz (en los módulos reutilizados del P2 se llama `clk_fpga`; se deja así). **Si se cambia una señal, se actualiza aquí** (fecha y motivo al final de este archivo).

## Diagrama de bloques

```
 teclado row[3:0] / col[3:0]
        │
        ▼
 ┌─────────────── lectura (4.1) ────────────────┐
 │ tk_columnas → avance_columnas ─► col[3:0]    │
 │ row ► sincronizar_filas ► DeBounce(prof.) ► deco_teclado
 │                          b_presionado, s_aviso│
 │                                 ▼             │
 │                           lectura_teclas      │──► PROD_SEL[1:0], IN_COINS[3:0], start, restart
 └───────────────────────────────────────────────┘            │
                                                              ▼
                                         ┌────────── fsm_vending (4.2, One-Hot) ──────────┐
                                         │ REPOSO CARGA CALCULO EVALUA DEC_INV ENTREGADO DEVOLUCION │
                                         └──┬────────────────────────────────▲────────────┘
              carga_precio, carga_monto,    │                                │ falta, agotado
              calcula_vuelto, dec_inv       ▼                                │
                                  ┌──── datapath_vending (4.3) ───────┐      │
                                  │ precio, credito = monedas×100,     │──────┘
                                  │ resta credito − precio (11 bits),  │
                                  │ inventario A/B/C (3 c/u)           │──► agotado_A/B/C
                                  └────────────┬──────────────────────┘
                                               │ vuelto[9:0]
                                               ▼
                                    display_subsystem (4.4) ──► seg[6:0], sel[3:0]

 FSM también saca: entrega (→ LED de producto), devuelve (→ LED de devolución)
```

## Señales entre módulos

| # | De → a | Señales | Notas |
|---|---|---|---|
| 1 | `top` → lectura | `clk_fpga`, `reset_B`, `row[3:0]` | `reset_B` = botón `resetn`, activo en bajo. Filas activas en bajo |
| 2 | lectura → `top` | `col[3:0]` | Barrido: 1110, 1101, 1011, 0111 (igual que P2) |
| 3 | `deco_teclado` → `lectura_teclas` | `b_presionado[4:0]`, `s_aviso` | Igual que P2. `s_aviso` = pulso de 1 ciclo. Códigos: 0–9 dígitos, 10=A, 11=B, 12=C, 13=D, 14=`*`, 15=`#` |
| 4 | `lectura_teclas` → FSM, datapath | `PROD_SEL[1:0]` | 00 ninguno, 01 A, 10 B, 11 C. Se queda guardado hasta cambiarlo o hasta `restart` |
| 5 | `lectura_teclas` → datapath | `IN_COINS[3:0]` | Número de monedas de ₡100 (0–9), último dígito presionado |
| 6 | `lectura_teclas` → FSM | `start` | Pulso de 1 ciclo al presionar **D** (solo se acepta con `PROD_SEL` ≠ 00) |
| 7 | `lectura_teclas` → FSM | `restart` | Pulso de 1 ciclo al presionar **\*** |
| 8 | FSM → datapath | `carga_precio` | 1 en `CARGA`: guarda el precio del producto elegido |
| 9 | FSM → datapath | `carga_monto` | 1 en `CARGA`: guarda crédito = `IN_COINS` × 100 (con `+` y desplazamientos) |
| 10 | FSM → datapath | `calcula_vuelto` | 1 en `CALCULO`: registra `crédito − precio` (11 bits, complemento a 2) |
| 11 | FSM → datapath | `dec_inv` | 1 en `DEC_INV`: resta 1 al inventario del producto elegido |
| 12 | datapath → FSM | `falta` | 1 si la resta dio negativo (signo = bit 10). Válida **un ciclo después** de `calcula_vuelto` (por eso `EVALUA` es un estado aparte) |
| 13 | datapath → FSM | `agotado` | 1 si el inventario del producto elegido es 0 |
| 13b | datapath → `top` | `prod_actual[1:0]` | Producto de la transacción en curso (01 A, 10 B, 11 C). El `top` lo usa para elegir qué LED de entrega se enciende |
| 14 | datapath → `top` | `agotado_A`, `agotado_B`, `agotado_C` | 1 = producto sin existencias → LED agotado |
| 15 | datapath → `top` → `display_subsystem` | `vuelto[9:0]` | Cambio en binario (0–750), 0 si falta. El `top` lo deja pasar solo cuando `entrega = 1` (si no, muestra 000) y entra a `bcd_converter` (10 bits) |
| 15b | `devuelve` → `temporizador_devolucion` → FSM | `fin_timer` | Pulso tras ~2 s (54 000 000 ciclos) en `DEVOLUCION` |
| 16 | FSM → `top` | `entrega`, `devuelve` | Moore. `entrega` → LED del producto elegido; `devuelve` → LED de devolución |
| 17 | `display_subsystem` → `top` | `seg[6:0]`, `sel[3:0]` | Activos en alto (cátodo común, NPN por dígito). Con `neg = 0` fijo |

## Entradas de la FSM (resumen)

`reset` (alto, asíncrono, estado inicial `REPOSO`), `start`, `restart`, `falta`, `agotado`, `fin_timer` (pulso del temporizador de devolución ~2 s; **opcional**: si no se hace, `DEVOLUCION` vuelve a `REPOSO` en 1 ciclo).

## Salidas de la FSM (todas Moore, cada una = un bit de estado One-Hot)

| Salida | Estado que la activa |
|---|---|
| `carga_precio`, `carga_monto` | `CARGA` |
| `calcula_vuelto` | `CALCULO` |
| `dec_inv` | `DEC_INV` |
| `entrega` | `ENTREGADO` |
| `devuelve` | `DEVOLUCION` |

## Puertos del `top` y pines

| Puerto | Dir. | Polaridad | Nota |
|---|---|---|---|
| `clk` | in | — | 27 MHz, pin 52 |
| `resetn` | in | activo en bajo | S1 global: reinicia FSM **y restaura inventario** (3 c/u) |
| `row[3:0]`, `col[3:0]` | in / out | filas activas en bajo | Igual que P2 |
| `seg[6:0]`, `sel[3:0]` | out | activo en alto | Igual que P2 |
| `led_entrega_n[2:0]` | out | **activo en bajo** | LEDs internos pines 10, 11, 13 (A, B, C) |
| `led_agotado_n[2:0]` | out | **activo en bajo** | LEDs internos pines 14, 15, 16 (A, B, C) |
| `led_devuelve` | out | activo en alto | LED externo + 330 Ω. Pin 26 |

## Uso de las teclas

| Tecla | Efecto |
|---|---|
| A, B, C | Elige el producto (A ₡150, B ₡275, C ₡400) |
| 0–9 | Número de monedas de ₡100 (queda la última presionada) |
| D | START |
| `*` | RESTART (vuelve a `REPOSO`, **no** borra el inventario) |
| `#` | Sin función |

## Reglas de diseño que afectan interfaces

- Precios y crédito en ₡; ancho de datos **11 bits con signo**: `crédito − precio` va de −400 a +750 con hasta 9 monedas (justificación para la bitácora).
- "Alcanza el crédito" sale **del signo de la resta**, no de un comparador.
- Todas las salidas de la FSM son Moore. Las salidas del datapath van registradas.
- `restart` y `start` son pulsos de 1 ciclo (vienen de `s_aviso`); la FSM no debe depender de que se mantengan.

## Cambios

| Fecha | Qué cambió | Motivo |
|---|---|---|
| 15-nov | Documento creado con el reparto acordado | Inicio del Proyecto 3 |
| 24-nov | Se agregan `prod_actual`, `fin_timer`, `teclado_top`, `lectura_teclas`, `vending_core`; `restart` limpia PROD_SEL e IN_COINS | Primer código del P3 |
