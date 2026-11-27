// Despliegue de 4 dígitos hexadecimales con apagado por dígito.
// Usa disp_hex_mux del profesor (multiplexado y decodificación) sin modificarlo.
// disp_hex_mux entrega an y sseg activos en BAJO; aquí se apaga el dígito pedido en blank
// y se invierte a activo en ALTO (NPN), igual que display_subsystem.
module display_4hex (
    input  logic       clk, reset,
    input  logic [3:0] hex3, hex2, hex1, hex0,
    input  logic [3:0] blank,           // 1 = dígito apagado (bit 3 = izquierdo)
    output logic [6:0] seg,             // a-g, activos en alto
    output logic [3:0] sel              // dígito activo, activo en alto
);

    logic [3:0] an;                     // salida de disp_hex_mux (activa en bajo)
    logic [7:0] sseg;                   // salida de disp_hex_mux (activa en bajo)
    logic [7:0] sseg_blank;             // sseg con los dígitos apagados

    disp_hex_mux mux_unit (
        .clk(clk),
        .reset(reset),
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),
        .dp_in(4'b1111),                // puntos decimales apagados
        .an(an),
        .sseg(sseg)
    );

    // Si el dígito activo está marcado en blank, sus segmentos se apagan (1 = apagado)
    always_comb begin
        sseg_blank = sseg;              // por defecto: lo que entrega disp_hex_mux
        if (an == 4'b0111 && blank[3]) sseg_blank = 8'b1111_1111;
        if (an == 4'b1011 && blank[2]) sseg_blank = 8'b1111_1111;
        if (an == 4'b1101 && blank[1]) sseg_blank = 8'b1111_1111;
        if (an == 4'b1110 && blank[0]) sseg_blank = 8'b1111_1111;
    end

    // Salidas registradas, ya invertidas a activo en alto
    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            seg <= 7'b000_0000;
            sel <= 4'b0000;
        end
        else begin
            seg <= ~sseg_blank[6:0];
            sel <= ~an;
        end

endmodule
