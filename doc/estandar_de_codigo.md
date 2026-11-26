# Estándar de código — Proyecto 3

Se mantiene el del Proyecto 2 (simple, legible, estilo del profesor, `logic`, `assign`, `always_comb`/`always_ff`, un reloj, `snake_case`, comentarios en español que explican el *por qué*, puertos con nombre, sin latches, `<=` en `always_ff` y `=` en `always_comb`, encabezado con autor, testbench con `OK`/`ERROR`). Ver el estándar del P2 si hace falta el detalle.

## Cambios respecto al P2 (los exige el enunciado del P3)

1. **FSM con `typedef enum` y One-Hot.** Ahora sí se usa `typedef enum logic [N-1:0]` con codificación one-hot en `fsm_vending` (sección 4.2). Es la **única** excepción: no se usa `enum` fuera de la FSM.
2. **Tres bloques separados en la FSM:** registro de estado (`always_ff`), lógica de siguiente estado (`always_comb`) y lógica de salidas (`always_comb`). Estado de reset definido (`REPOSO`) y sin latches.
3. **Comentarios siempre en español**, también dentro de la FSM (se ignora el requisito del enunciado de comentar en otro idioma).
4. **Ecuaciones visibles:** las ecuaciones de siguiente estado van en un comentario sobre el bloque y en el documento de la FSM.
5. **Operador `-` permitido en el P3** (el enunciado permite `+` y `−` en complemento a 2). Aun así se prefiere `A + ~B + 1`, como en el P2, porque deja claro de dónde sale el signo.
6. **Código del profesor obligatorio** (DeBounce y BCD), sin modificar. Quitarlo cuesta −10 %.
7. Sigue prohibido: `struct`, `package`, `interface`, `generate`, `function` en diseño.
