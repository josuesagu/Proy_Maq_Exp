// Núcleo de la máquina: FSM + datapath + temporizador. Sin teclado ni display, para simular el sistema.
// Autor: Josué
module vending_core #(parameter CICLOS_DEV = 54_000_000) (
    input  logic       clk, reset,
    input  logic [1:0] prod_sel,
    input  logic [3:0] in_coins,
    input  logic       start, restart,
    output logic       entrega, devuelve,
    output logic [1:0] prod_actual,
    output logic [9:0] vuelto,
    output logic       agotado_A, agotado_B, agotado_C
);

    logic carga_precio, carga_monto, calcula_vuelto, dec_inv;
    logic falta, agotado, fin_timer;

    fsm_vending fsm (
        .clk(clk), .reset(reset), .start(start), .restart(restart),
        .falta(falta), .agotado(agotado), .fin_timer(fin_timer),
        .carga_precio(carga_precio), .carga_monto(carga_monto),
        .calcula_vuelto(calcula_vuelto), .dec_inv(dec_inv),
        .entrega(entrega), .devuelve(devuelve)
    );

    datapath_vending dp (
        .clk(clk), .reset(reset), .prod_sel(prod_sel), .in_coins(in_coins),
        .carga_precio(carga_precio), .carga_monto(carga_monto),
        .calcula_vuelto(calcula_vuelto), .dec_inv(dec_inv),
        .falta(falta), .agotado(agotado), .prod_actual(prod_actual), .vuelto(vuelto),
        .agotado_A(agotado_A), .agotado_B(agotado_B), .agotado_C(agotado_C)
    );

    temporizador_devolucion #(.CICLOS(CICLOS_DEV)) timer (
        .clk(clk), .reset(reset), .activo(devuelve), .fin_timer(fin_timer)
    );

endmodule
