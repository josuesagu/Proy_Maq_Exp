// Subsistema de lectura (4.1), parte física: barrido, sincronización, DeBounce y decodificación.
// Es el mismo cableado de insercion_top del Proyecto 2, sin la FSM ni los registros de números.
// Salida: la tecla presionada (b_presionado) y un pulso de 1 ciclo (s_aviso).
module teclado_top (
    input  logic       clk_fpga,
    input  logic       reset_B,        // activo en bajo (botón)
    input  logic [3:0] f_tecl,         // filas del teclado (activas en bajo)
    output logic [3:0] ubic_c,         // columnas del teclado (barrido)
    output logic [4:0] b_presionado,   // código de la tecla (0-9, 10=A ... 15=#)
    output logic       s_aviso         // pulso de 1 ciclo: tecla nueva
);

    logic [3:0] f_sinc;                // filas sincronizadas
    logic [3:0] f_listas;              // filas filtradas por el DeBounce
    logic       TK_C;                  // tick de 1 ms

    sincronizar_filas bloque_sinc (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .f_tecl   (f_tecl),
        .f_sinc   (f_sinc)
    );

    // DeBounce del profesor, una instancia por fila (N = 21 -> ventana de 38.8 ms)
    DeBounce #(.N(21)) deb_f0 (.clk(clk_fpga), .n_reset(reset_B), .button_in(f_sinc[0]), .DB_out(f_listas[0]));
    DeBounce #(.N(21)) deb_f1 (.clk(clk_fpga), .n_reset(reset_B), .button_in(f_sinc[1]), .DB_out(f_listas[1]));
    DeBounce #(.N(21)) deb_f2 (.clk(clk_fpga), .n_reset(reset_B), .button_in(f_sinc[2]), .DB_out(f_listas[2]));
    DeBounce #(.N(21)) deb_f3 (.clk(clk_fpga), .n_reset(reset_B), .button_in(f_sinc[3]), .DB_out(f_listas[3]));

    tk_columnas bloque_tick (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .TK_C     (TK_C)
    );

    avance_columnas bloque_anillo (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .TK_C     (TK_C),
        .f_sinc   (f_sinc),
        .f_listas (f_listas),
        .ubic_c   (ubic_c)
    );

    deco_teclado bloque_deco (
        .clk_fpga     (clk_fpga),
        .reset_B      (reset_B),
        .f_listas     (f_listas),
        .ubic_c       (ubic_c),
        .b_presionado (b_presionado),
        .s_aviso      (s_aviso)
    );

endmodule
