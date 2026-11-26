# Guía de montaje del Proyecto 3 (máquina expendedora)

Para Ariel · EL-3307 Diseño Lógico, II Sem 2026. Coincide con `src/constr/proyecto3.cst`. Si cambian un pin, cambien el `.cst` **y** esta guía.

**Buena noticia:** es casi el mismo circuito del Proyecto 2 (teclado + 4 displays). Lo único nuevo es **un LED externo** (devolución de monedas). Los otros 6 LEDs ya vienen en la placa y no se cablean.

---

## 1. El circuito completo en una imagen

```
 TECLADO 4x4                      Tang Nano 9K                       DISPLAYS (cátodo común)
 col0 ◄─[330Ω]─ pin 25 ┐                                    pin 35 ─[220Ω]─► seg a ┐
 col1 ◄─[330Ω]─ pin 30 │                                    pin 40 ─[220Ω]─► seg b │
 col2 ◄─[330Ω]─ pin 27 │ salidas                            pin 41 ─[220Ω]─► seg c │ los 4 dígitos
 col3 ◄─[330Ω]─ pin 28 ┘                                    pin 42 ─[220Ω]─► seg d │ en paralelo
 fila0 ────────► pin 29 ┐                                   pin 51 ─[220Ω]─► seg e │
 fila1 ────────► pin 37 │ entradas                          pin 53 ─[220Ω]─► seg f │
 fila2 ────────► pin 33 │ (pull-up interno)                 pin 54 ─[220Ω]─► seg g ┘
 fila3 ────────► pin 34 ┘
                                                  pin 55 ─[470Ω]─► base NPN 0 (unidades)
 LED DE DEVOLUCIÓN (nuevo)                        pin 56 ─[470Ω]─► base NPN 1 (decenas)
 pin 26 ─[330Ω]─► LED (+) ... LED (−) ─► GND      pin 57 ─[470Ω]─► base NPN 2 (centenas)
                                                  pin 36 ─[470Ω]─► base NPN 3 (izquierda)
 LEDs internos de la placa: no se cablean         colector de cada NPN → cátodo común de su dígito
 botón reset: pin 4 (ya está en la placa)         emisor de los 4 NPN → GND
```

Todo funciona a **3.3 V** con la alimentación del USB. **Nunca 5 V hacia pines de la FPGA.** Solo hay **un pin GND** en el header: llévenlo a un riel de la protoboard y de ahí a todo lo demás.

---

## 2. Qué cambia respecto al Proyecto 2

| Cosa | P2 | P3 |
|---|---|---|
| Teclado | calculadora | A, B, C = producto · 0–9 = monedas · D = START · `*` = RESTART |
| Displays | mostraban operandos y resultado | muestran el **vuelto** (y 000 el resto del tiempo) |
| Dígito de la izquierda (pin 36) | signo menos | apagado (se usa en el display extra, si se hace) |
| LEDs | ninguno | 6 internos de la placa + **1 externo** |
| Cableado | — | **igual**, más el LED externo en el pin 26 |

Si el montaje del P2 sigue armado, **no hay que tocar nada** excepto agregar el LED.

---

## 3. Materiales

| Cant. | Elemento | Para qué |
|---|---|---|
| 1 | Tang Nano 9K + cable USB-C | |
| 1 | Protoboard (grande o dos) | |
| 1 | Teclado matricial 4x4 (Grayhill 96BB2-006-F) | entrada |
| 4 | Displays 7 segmentos **cátodo común** (o módulo de 4 dígitos) | vuelto |
| 4 | Transistores NPN (2N3904, BC547 o 2N2222) | activar cada dígito |
| 7 | Resistencias 220 Ω | una por segmento |
| 4 | Resistencias 470 Ω | base de cada NPN |
| 5 | Resistencias 330 Ω | 4 en las columnas + **1 para el LED externo** |
| 1 | **LED de 5 mm** (rojo, de preferencia) | devolución de monedas |
| ~30 | Cables jumper | |
| 1 | Multímetro | medir y verificar |

---

## 4. Tabla de pines (la única que necesitan)

| Señal | Pin | Se conecta a |
|---|---|---|
| col[0] | 25 | 330 Ω → columna 0 del teclado |
| col[1] | 30 | 330 Ω → columna 1 |
| col[2] | 27 | 330 Ω → columna 2 |
| col[3] | 28 | 330 Ω → columna 3 |
| row[0] | 29 | fila 0 (directo, sin resistencia) |
| row[1] | 37 | fila 1 (directo) |
| row[2] | 33 | fila 2 (directo) |
| row[3] | 34 | fila 3 (directo) |
| seg[6] (a) | 35 | 220 Ω → segmento a |
| seg[5] (b) | 40 | 220 Ω → b |
| seg[4] (c) | 41 | 220 Ω → c |
| seg[3] (d) | 42 | 220 Ω → d |
| seg[2] (e) | 51 | 220 Ω → e |
| seg[1] (f) | 53 | 220 Ω → f |
| seg[0] (g) | 54 | 220 Ω → g |
| sel[0] unidades | 55 | 470 Ω → base NPN 0 |
| sel[1] decenas | 56 | 470 Ω → base NPN 1 |
| sel[2] centenas | 57 | 470 Ω → base NPN 2 |
| sel[3] izquierda | 36 | 470 Ω → base NPN 3 |
| **led_devuelve** | **26** | **330 Ω → LED (+); LED (−) → GND** |
| clk / resetn | 52 / 4 | internos, no se cablean |
| LEDs internos | 10, 11, 13, 14, 15, 16 | internos, no se cablean |

Header **izquierdo**, de arriba hacia abajo (el 40 va antes que el 35): `38, 37, 36, 39, 25, 26, 27, 28, 29, 30, 33, 34, 40, 35, 41, 42, 51, 53, 54, 55, 56, 57, 68, 69`. El pin 26 está justo debajo del 25.

Notas:
- No pongan nada en los conectores LCD y SD de la placa (comparten pines con los displays).
- Si la fila 1 (4, 5, 6, B) no responde, el pin 37 es el sospechoso (es el que no estaba verificado en el P2).

---

## 5. Montaje paso a paso

Cada paso se prueba **antes** del siguiente. Con el USB desconectado mientras alambran.

### Paso 0 — Medir el teclado (solo si no tienen la tabla del P2)
Con el multímetro en continuidad, identifiquen cuál de los 8 pines del teclado es cada fila y columna: las teclas 1, 2, 3, A comparten la fila 0; 1, 4, 7, `*` comparten la columna 0; y así. Si ya tienen la tabla del P2, úsenla.

### Paso 1 — Displays
1. Los 7 segmentos: cada pin (35, 40, 41, 42, 51, 53, 54) → una resistencia de 220 Ω → el segmento correspondiente (a–g), **compartido por los 4 dígitos**. El punto decimal no se conecta.
2. Cada dígito tiene su cátodo común → colector de su NPN. Emisor de los 4 NPN → GND.
3. Base de cada NPN → 470 Ω → pin 55, 56, 57 y 36 (unidades, decenas, centenas, izquierda).
4. Orden físico recomendado, de izquierda a derecha: **izquierda (36), centenas, decenas, unidades**.
5. Verifiquen la orientación E-B-C del transistor con el datasheet o el multímetro en modo diodo (el 2N3904 y el BC547 no tienen el mismo orden).

**Prueba:** desde `src/build`:
```
make all TOP_DESIGN=top_prueba_display CONSTRAINTS=../constr/prueba_display.cst
```
Deben ver, cada ~1.2 s: `888`, `-123`, `456`, `-999` (el signo `-` aparece en el dígito de la izquierda). **No sigan hasta que se vea bien.**

### Paso 2 — Teclado
1. Columnas: pines 25, 30, 27, 28 → una resistencia de 330 Ω cada una → columnas 0, 1, 2, 3 del teclado.
2. Filas: pines 29, 37, 33, 34 → directo a las filas 0, 1, 2, 3. **Sin resistencias** (usan el pull-up interno).
3. Fijen bien los 8 contactos: los contactos flojos dan teclas fantasma.

**Prueba:**
```
make all TOP_DESIGN=top_prueba_teclado
```
Al presionar una tecla, el display muestra su código: `1 2 3 A → 1 2 3 10` · `4 5 6 B → 4 5 6 11` · `7 8 9 C → 7 8 9 12` · `* 0 # D → 14 0 15 13`. Prueben **las 16 teclas**, una por una, y también varias seguidas (en el P2 hubo un problema con teclas pegadas; si vuelve a pasar, avísenme antes de seguir).

### Paso 3 — LED externo de devolución (lo nuevo)
```
pin 26 ──[330 Ω]──► pata larga del LED (ánodo, +)
                    pata corta del LED (cátodo, −) ──► GND
```
- La pata **larga** es el ánodo (+) y va hacia la resistencia/pin; la corta, a GND.
- Con el USB desconectado, prueben el LED sacando temporalmente la resistencia de 330 Ω y poniéndola entre 3V3 y el LED: si enciende, está bien orientado.

### Paso 4 — Cargar el diseño completo
```
make all
```
(el top y el `.cst` por defecto ya son los del P3). Si `openFPGALoader` falla con "usb bulk write failed": cambien de puerto USB y desconecten un momento los cables de la protoboard para cargar. Recuerden que **al quitar el USB el diseño se pierde** (SRAM): hay que cargar de nuevo.

---

## 6. LEDs internos de la placa (no se cablean)

Se encienden con 0, ya está resuelto en el código. Van en este orden, de LED0 a LED5 (pines 10, 11, 13, 14, 15, 16):

| LED de la placa | Significa |
|---|---|
| LED0 | entrega producto **A** |
| LED1 | entrega producto **B** |
| LED2 | entrega producto **C** |
| LED3 | producto **A** agotado |
| LED4 | producto **B** agotado |
| LED5 | producto **C** agotado |

Si al presionar `A 2 D` se enciende un LED que no es el LED0, avísenme: puede que la serigrafía de la placa no coincida con el orden de los pines y se ajusta en el `.cst`.

---

## 7. Pruebas funcionales con el diseño completo

Los displays muestran el producto, las monedas y el vuelto (`_` = dígito apagado):
reposo `A _ _ 2` · entrega `A 0 5 0` · devolución `A d _ 2`. Secuencia de teclas: producto → monedas → **D**. Después de una entrega hay que presionar `*` (RESTART) antes de otra compra.

| # | Teclas | Resultado esperado |
|---|---|---|
| 1 | Reset (botón de la placa) | displays apagados, LEDs de entrega y devolución apagados |
| 2 | `C` | display `C _ _ 0` |
| 3 | `4` | display `C _ _ 4` |
| 4 (a) | `D` | LED2 (C) encendido, display `C 0 0 0` (pago exacto) → `*` |
| 5 (b) | `A` `2` `D` | LED0 (A) encendido, display `A 0 5 0` (vuelto) → `*` |
| 6 | `B` `3` `D` | LED1 (B) encendido, display `b 0 2 5` → `*` |
| 7 (c) | `C` `3` `D` | LED externo de devolución ~2 s, display `C d _ 3`, ningún LED de entrega |
| 8 (d) | `A` `2` `D` `*` (tres veces) | tras la 3.ª compra se enciende LED3 (A agotado) |
| 9 (d) | `A` `2` `D` | la 4.ª compra devuelve las monedas (LED externo ~2 s) |
| 10 | `B` `3` `D` | B todavía se entrega: el inventario de B no se borró |
| 11 | Reset | LED3 se apaga: el inventario volvió a 3 |
| 12 | `A` `2` `D` y luego `*` | vuelve a reposo sin tocar el inventario |

Anoten el resultado de cada fila en la bitácora.

---

## 8. Solución de problemas

| Problema | Qué revisar |
|---|---|
| Un segmento nunca prende en **ningún** dígito | su resistencia/cable/pin |
| Un dígito no prende | su NPN (E y C invertidos) o su cátodo |
| Display muy tenue | resistencias muy altas o falta GND en emisores |
| Una **fila** del teclado no responde | cable y pin de esa fila (sospechoso: 37) |
| Una **columna** no responde | su resistencia de 330 Ω |
| Teclas equivocadas | filas/columnas invertidas: revisen la tabla del paso 0 |
| Teclas fantasma o repetidas | contactos flojos |
| LED externo no enciende | polaridad del LED, resistencia, pin 26 |
| LED externo siempre encendido | revisen que no esté sobre el pin 25 o 27 por error |
| La placa se calienta | corto entre 3V3 y GND: desconecten y revisen |
| Se pierde todo al quitar el USB | normal (SRAM) |

---

## 9. Lista de verificación antes de energizar

- [ ] Tabla de pines del teclado medida (o la del P2 a mano)
- [ ] GND de la placa unido al riel y a los emisores de los 4 NPN
- [ ] Ningún cable de 5 V a pines de la FPGA
- [ ] 4 × 330 Ω en las columnas y **ninguna** en las filas
- [ ] 7 × 220 Ω en los segmentos · 4 × 470 Ω en las bases
- [ ] Orientación E-B-C de los 4 transistores verificada
- [ ] LED externo con 330 Ω, ánodo al pin 26, cátodo a GND
- [ ] Nada conectado en los conectores LCD/SD
- [ ] Pines coinciden con `proyecto3.cst`

## 10. Qué anotar en la bitácora

Fecha, esquema de conexiones dibujado a mano, tabla del teclado, resultado de las pruebas de los pasos 1, 2 y 7, y los problemas encontrados con su solución.
