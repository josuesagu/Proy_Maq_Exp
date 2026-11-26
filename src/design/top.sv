// Top del Proyecto 3: máquina expendedora en la Tang Nano 9K.
// teclado -> lectura_teclas -> vending_core (FSM + datapath) -> LEDs y display (vuelto).
// resetn (botón, activo en bajo) va directo al teclado/DeBounce; el resto usa reset = ~resetn (activo en alto).
// Autor: Josué
module top (
    input  logic       clk,
    input  logic       resetn,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] sel,
    output logic [2:0] led_entrega_n,     // internos, activos en bajo (A, B, C)
    output logic [2:0] led_agotado_n,     // internos, activos en bajo (A, B, C)
    output logic       led_devuelve       // externo, activo en alto
);

    logic       reset;
    logic [4:0] b_presionado;
    logic       s_aviso;
    logic [1:0] prod_sel, prod_actual;
    logic [3:0] in_coins;
    logic       start, restart;
    logic       entrega, devuelve;
    logic [9:0] vuelto, valor;
    logic       agotado_A, agotado_B, agotado_C;

    assign reset = ~resetn;

    teclado_top teclado (
        .clk_fpga(clk), .reset_B(resetn), .f_tecl(row), .ubic_c(col),
        .b_presionado(b_presionado), .s_aviso(s_aviso)
    );

    lectura_teclas lectura (
        .clk(clk), .reset(reset), .b_presionado(b_presionado), .s_aviso(s_aviso),
        .prod_sel(prod_sel), .in_coins(in_coins), .start(start), .restart(restart)
    );

    vending_core #(.CICLOS_DEV(54_000_000)) core (
        .clk(clk), .reset(reset), .prod_sel(prod_sel), .in_coins(in_coins),
        .start(start), .restart(restart), .entrega(entrega), .devuelve(devuelve),
        .prod_actual(prod_actual), .vuelto(vuelto),
        .agotado_A(agotado_A), .agotado_B(agotado_B), .agotado_C(agotado_C)
    );

    // El display muestra el vuelto solo mientras se entrega; si no, 000
    assign valor = entrega ? vuelto : 10'd0;

    display_subsystem display (
        .clk(clk), .reset(reset), .value(valor), .neg(1'b0), .seg(seg), .sel(sel)
    );

    // LEDs (los internos de la placa se encienden con 0)
    assign led_entrega_n[0] = ~(entrega && prod_actual == 2'b01);
    assign led_entrega_n[1] = ~(entrega && prod_actual == 2'b10);
    assign led_entrega_n[2] = ~(entrega && prod_actual == 2'b11);
    assign led_agotado_n    = ~{agotado_C, agotado_B, agotado_A};
    assign led_devuelve     = devuelve;

endmodule
