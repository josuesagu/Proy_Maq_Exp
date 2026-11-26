// Testbench del sistema (FSM + datapath + temporizador): los 4 casos obligatorios del enunciado.
`timescale 1ns/1ps
module vending_core_tb;

    logic       clk = 0, reset;
    logic [1:0] prod_sel;
    logic [3:0] in_coins;
    logic       start, restart;
    logic       entrega, devuelve;
    logic [1:0] prod_actual;
    logic [9:0] vuelto;
    logic       agotado_A, agotado_B, agotado_C;
    int         errores = 0;

    vending_core #(.CICLOS_DEV(20)) dut (.*);

    always #18.52 clk = ~clk;   // 27 MHz

    task automatic pulso_start;
        @(negedge clk); start = 1; @(negedge clk); start = 0;
    endtask

    task automatic pulso_restart;
        @(negedge clk); restart = 1; @(negedge clk); restart = 0;
    endtask

    // Espera hasta que se entregue o se devuelva (con tope para no colgarse)
    task automatic espera_resultado;
        int n = 0;
        while (!entrega && !devuelve && n < 100) begin @(negedge clk); n++; end
    endtask

    task automatic verifica(input string nombre, input logic esp_entrega, input logic esp_devuelve,
                            input logic [9:0] esp_vuelto);
        if (entrega === esp_entrega && devuelve === esp_devuelve && (!esp_entrega || vuelto === esp_vuelto))
            $display("OK    %s (entrega=%b devuelve=%b vuelto=%0d)", nombre, entrega, devuelve, vuelto);
        else begin
            $display("ERROR %s: entrega=%b devuelve=%b vuelto=%0d", nombre, entrega, devuelve, vuelto);
            errores++;
        end
    endtask

    // Termina la transaccion: restart si se entrego, o espera el timer si se devolvio
    task automatic termina;
        if (entrega) pulso_restart;
        else begin repeat (30) @(negedge clk); end
        repeat (3) @(negedge clk);
    endtask

    initial begin
        reset = 1; start = 0; restart = 0; prod_sel = 0; in_coins = 0;
        repeat (3) @(negedge clk); reset = 0; repeat (2) @(negedge clk);

        // (a) pago exacto: C (400) con 4 monedas, vuelto 0
        prod_sel = 2'b11; in_coins = 4'd4; pulso_start; espera_resultado;
        verifica("a) C con 4 monedas, vuelto 0", 1, 0, 10'd0);
        if (prod_actual !== 2'b11) begin $display("ERROR a) prod_actual"); errores++; end
        termina;

        // (b) sobrepago: A (150) con 2 monedas, vuelto 50
        prod_sel = 2'b01; in_coins = 4'd2; pulso_start; espera_resultado;
        verifica("b) A con 2 monedas, vuelto 50", 1, 0, 10'd50);
        termina;

        // (c) pago insuficiente: C con 3 monedas, devuelve
        prod_sel = 2'b11; in_coins = 4'd3; pulso_start; espera_resultado;
        verifica("c) C con 3 monedas, devuelve", 0, 1, 10'd0);
        termina;
        verifica("c) vuelve a reposo", 0, 0, 10'd0);

        // B (275) con 3 monedas: vuelto 25
        prod_sel = 2'b10; in_coins = 4'd3; pulso_start; espera_resultado;
        verifica("B con 3 monedas, vuelto 25", 1, 0, 10'd25);
        termina;

        // (d) agotado: A ya se vendio 1 vez en (b); 2 compras mas la agotan y la 4a se devuelve
        prod_sel = 2'b01; in_coins = 4'd2;
        pulso_start; espera_resultado; verifica("d) A compra 2", 1, 0, 10'd50); termina;
        pulso_start; espera_resultado; verifica("d) A compra 3", 1, 0, 10'd50); termina;
        if (agotado_A !== 1'b1) begin $display("ERROR d) agotado_A debia ser 1"); errores++; end
        else $display("OK    d) agotado_A = 1");
        pulso_start; espera_resultado; verifica("d) A compra 4: devuelve", 0, 1, 10'd0); termina;
        if (agotado_B !== 1'b0 || agotado_C !== 1'b0) begin $display("ERROR d) B o C no deben estar agotados"); errores++; end
        else $display("OK    d) restart/devolucion no borra inventario de B ni C");

        // el reset (S1) restaura el inventario
        reset = 1; repeat (2) @(negedge clk); reset = 0; repeat (2) @(negedge clk);
        if (agotado_A !== 1'b0) begin $display("ERROR reset no restauro inventario"); errores++; end
        else $display("OK    reset restaura inventario");

        if (errores == 0) $display("TODO OK");
        else              $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

    initial begin
        $dumpfile("vending_core_tb.vcd");
        $dumpvars(0, vending_core_tb);
    end

endmodule
