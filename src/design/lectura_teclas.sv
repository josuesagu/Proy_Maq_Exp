// Subsistema de lectura (4.1), parte lógica: convierte teclas en PROD_SEL, IN_COINS, start y restart.
//   A, B, C  -> producto (01, 10, 11)       0-9 -> monedas de 100 (queda la última)
//   D        -> start (solo si ya hay producto)       * -> restart (borra la selección)
// start y restart salen registrados, pulsos de 1 ciclo.
module lectura_teclas (
    input  logic       clk, reset,          // reset activo en alto
    input  logic [4:0] b_presionado,
    input  logic       s_aviso,
    output logic [1:0] prod_sel,            // 00 ninguno, 01 A, 10 B, 11 C
    output logic [3:0] in_coins,            // monedas de 100 (0-9)
    output logic       start,
    output logic       restart
);

    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            prod_sel <= 2'b00;
            in_coins <= 4'd0;
            start    <= 1'b0;
            restart  <= 1'b0;
        end
        else begin
            start   <= 1'b0;                // por defecto: sin pulso
            restart <= 1'b0;
            if (s_aviso) begin
                if      (b_presionado == 5'd10) prod_sel <= 2'b01;   // A
                else if (b_presionado == 5'd11) prod_sel <= 2'b10;   // B
                else if (b_presionado == 5'd12) prod_sel <= 2'b11;   // C
                else if (b_presionado <= 5'd9)  in_coins <= b_presionado[3:0];   // dígito
                else if (b_presionado == 5'd13) start    <= (prod_sel != 2'b00); // D
                else if (b_presionado == 5'd14) begin                            // *
                    restart  <= 1'b1;
                    prod_sel <= 2'b00;
                    in_coins <= 4'd0;
                end
            end
        end

endmodule
