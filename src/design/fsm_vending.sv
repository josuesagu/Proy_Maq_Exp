// Subsistema FSM (4.2): máquina expendedora, One-Hot, salidas Moore (cada salida = un bit de estado)
// Ecuaciones de siguiente estado (~ = negación, · = AND, + = OR):
//   REPOSO_sig     = REPOSO·~start + ENTREGADO·restart + DEVOLUCION·fin_timer
//   CARGA_sig      = REPOSO·start
//   CALCULO_sig    = CARGA
//   EVALUA_sig     = CALCULO
//   DEC_INV_sig    = EVALUA·~agotado·~falta
//   ENTREGADO_sig  = DEC_INV + ENTREGADO·~restart
//   DEVOLUCION_sig = EVALUA·(agotado + falta) + DEVOLUCION·~fin_timer
// El reset (asíncrono, activo en alto) lleva el registro a REPOSO.
module fsm_vending (
    input  logic clk, reset,
    input  logic start, restart,
    input  logic falta, agotado,
    input  logic fin_timer,
    output logic carga_precio, carga_monto,
    output logic calcula_vuelto, dec_inv,
    output logic entrega, devuelve
);

    // Estados, codificación One-Hot (un bit por estado)
    typedef enum logic [6:0] {
        REPOSO    = 7'b0000001,
        CARGA     = 7'b0000010,
        CALCULO   = 7'b0000100,
        EVALUA    = 7'b0001000,
        DEC_INV   = 7'b0010000,
        ENTREGADO = 7'b0100000,
        DEVOLUCION= 7'b1000000
    } estado_t;

    estado_t state_reg, state_next;

    // Registro de estado: el reset lo lleva a REPOSO
    always_ff @(posedge clk, posedge reset)
        if (reset) state_reg <= REPOSO;
        else       state_reg <= state_next;

    // Siguiente estado (solo lógica combinacional, sin latches)
    always_comb begin
        state_next = state_reg;                 // por defecto: se queda en el mismo estado
        case (state_reg)
            REPOSO:     if (start)                  state_next = CARGA;
            CARGA:                                  state_next = CALCULO;
            CALCULO:                                state_next = EVALUA;    // el signo de la resta es válido un ciclo después
            EVALUA:     if (agotado || falta)       state_next = DEVOLUCION;
                        else                        state_next = DEC_INV;
            DEC_INV:                                state_next = ENTREGADO;
            ENTREGADO:  if (restart)                state_next = REPOSO;
            DEVOLUCION: if (fin_timer)              state_next = REPOSO;
            default:                                state_next = REPOSO;    // estado ilegal: vuelve a REPOSO
        endcase
    end

    // Salidas (Moore): cada salida depende solo del estado
    assign carga_precio   = (state_reg == CARGA);
    assign carga_monto    = (state_reg == CARGA);
    assign calcula_vuelto = (state_reg == CALCULO);
    assign dec_inv        = (state_reg == DEC_INV);
    assign entrega        = (state_reg == ENTREGADO);
    assign devuelve       = (state_reg == DEVOLUCION);

endmodule
