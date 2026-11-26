// Testbench del sistema completo: teclado simulado -> top -> LEDs.
// Se acortan el DeBounce (N = 4) y el temporizador de devolución con defparam para que la simulación sea corta.
// Los 4 casos del enunciado se hacen con teclas, como en la placa.
`timescale 1ns/1ps
module top_tb;

    logic       clk = 0, resetn;
    logic [3:0] row, col;
    logic [6:0] seg;
    logic [3:0] sel;
    logic [2:0] led_entrega_n, led_agotado_n;
    logic       led_devuelve;
    logic [4:0] tecla_pulsada;          // 16 = ninguna
    int         errores = 0;
    logic       vio_devuelve = 0;       // se pone en 1 si led_devuelve se enciende alguna vez (la devolución dura menos que la tecla)

    top dut (
        .clk(clk), .resetn(resetn), .row(row), .col(col), .seg(seg), .sel(sel),
        .led_entrega_n(led_entrega_n), .led_agotado_n(led_agotado_n), .led_devuelve(led_devuelve)
    );

    // Valores de simulación (no cambian el diseño real)
    defparam dut.teclado.deb_f0.N = 4;
    defparam dut.teclado.deb_f1.N = 4;
    defparam dut.teclado.deb_f2.N = 4;
    defparam dut.teclado.deb_f3.N = 4;
    defparam dut.core.timer.CICLOS = 3000;

    always #18.52 clk = ~clk;

    // Modelo del teclado: una fila baja a 0 si la tecla pulsada está en la columna activa (col en 0)
    always_comb begin
        row = 4'b1111;
        case (tecla_pulsada)
            5'd1:  if (!col[0]) row[0] = 0;   5'd2:  if (!col[1]) row[0] = 0;
            5'd3:  if (!col[2]) row[0] = 0;   5'd10: if (!col[3]) row[0] = 0;
            5'd4:  if (!col[0]) row[1] = 0;   5'd5:  if (!col[1]) row[1] = 0;
            5'd6:  if (!col[2]) row[1] = 0;   5'd11: if (!col[3]) row[1] = 0;
            5'd7:  if (!col[0]) row[2] = 0;   5'd8:  if (!col[1]) row[2] = 0;
            5'd9:  if (!col[2]) row[2] = 0;   5'd12: if (!col[3]) row[2] = 0;
            5'd14: if (!col[0]) row[3] = 0;   5'd0:  if (!col[1]) row[3] = 0;
            5'd15: if (!col[2]) row[3] = 0;   5'd13: if (!col[3]) row[3] = 0;
            default: row = 4'b1111;
        endcase
    end

    always @(posedge led_devuelve) vio_devuelve = 1;

    // Presiona una tecla: la mantiene más de un barrido completo de columnas y la suelta
    task automatic pulsa(input logic [4:0] k);
        tecla_pulsada = k;
        repeat (150_000) @(posedge clk);
        tecla_pulsada = 5'd16;
        repeat (150_000) @(posedge clk);
    endtask

    task automatic espera(input int ciclos);
        repeat (ciclos) @(posedge clk);
    endtask

    task automatic revisa(input string nombre, input logic [2:0] esp_entrega, input logic esp_devuelve);
        if (~led_entrega_n === esp_entrega && led_devuelve === esp_devuelve)
            $display("OK    %s (entrega=%b devuelve=%b)", nombre, ~led_entrega_n, led_devuelve);
        else begin
            $display("ERROR %s: entrega=%b devuelve=%b (esperado %b %b)", nombre, ~led_entrega_n, led_devuelve,
                     esp_entrega, esp_devuelve);
            errores++;
        end
    endtask

    initial begin
        tecla_pulsada = 5'd16; resetn = 0;
        espera(10); resetn = 1; espera(100);

        // (a) pago exacto: C con 4 monedas
        pulsa(5'd12); pulsa(5'd4); pulsa(5'd13); espera(50);
        revisa("a) C, 4 monedas, D -> LED de C", 3'b100, 0);
        pulsa(5'd14);                                   // * = RESTART

        // (b) sobrepago: A con 2 monedas (vuelto 50)
        pulsa(5'd10); pulsa(5'd2); pulsa(5'd13); espera(50);
        revisa("b) A, 2 monedas, D -> LED de A", 3'b001, 0);
        if (dut.vuelto === 10'd50) $display("OK    b) vuelto = 50");
        else begin $display("ERROR b) vuelto = %0d", dut.vuelto); errores++; end
        pulsa(5'd14);

        // (c) pago insuficiente: C con 3 monedas
        vio_devuelve = 0;
        pulsa(5'd12); pulsa(5'd3); pulsa(5'd13); espera(50);
        if (vio_devuelve) $display("OK    c) C, 3 monedas, D -> se encendio el LED de devolucion");
        else begin $display("ERROR c) no se encendio el LED de devolucion"); errores++; end
        revisa("c) vuelve a reposo, sin entrega", 3'b000, 0);
        pulsa(5'd14);

        // (d) agotado: A tres veces y una cuarta
        pulsa(5'd10); pulsa(5'd2);
        pulsa(5'd13); espera(50); pulsa(5'd14);          // venta 2 de A (la 1.a fue en b)
        pulsa(5'd10); pulsa(5'd2);
        pulsa(5'd13); espera(50);
        if (led_agotado_n[0] === 1'b0) $display("OK    d) LED de A agotado");
        else begin $display("ERROR d) LED de A agotado apagado"); errores++; end
        pulsa(5'd14);
        vio_devuelve = 0;
        pulsa(5'd10); pulsa(5'd2); pulsa(5'd13); espera(50);
        if (vio_devuelve && ~led_entrega_n === 3'b000) $display("OK    d) 4.a compra de A -> devuelve");
        else begin $display("ERROR d) 4.a compra de A no devolvio"); errores++; end

        if (errores == 0) $display("TODO OK"); else $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

endmodule
