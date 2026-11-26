// Testbench del datapath solo: se mueven las órdenes de la FSM a mano y se revisan resta, signo e inventario.
`timescale 1ns/1ps
module datapath_vending_tb;

    logic       clk = 0, reset;
    logic [1:0] prod_sel;
    logic [3:0] in_coins;
    logic       carga_precio, carga_monto, calcula_vuelto, dec_inv;
    logic       falta, agotado;
    logic [1:0] prod_actual;
    logic [9:0] vuelto;
    logic       agotado_A, agotado_B, agotado_C;
    int         errores = 0;

    datapath_vending dut (.*);

    always #18.52 clk = ~clk;

    // Hace lo mismo que la FSM: CARGA, CALCULO y luego se lee falta/vuelto
    task automatic calcula(input logic [1:0] p, input logic [3:0] m,
                           input logic esp_falta, input logic [9:0] esp_vuelto);
        prod_sel = p; in_coins = m;
        @(negedge clk); carga_precio = 1; carga_monto = 1;
        @(negedge clk); carga_precio = 0; carga_monto = 0; calcula_vuelto = 1;
        @(negedge clk); calcula_vuelto = 0;
        @(negedge clk);
        if (falta === esp_falta && vuelto === esp_vuelto)
            $display("OK    prod=%0d monedas=%0d -> falta=%b vuelto=%0d", p, m, falta, vuelto);
        else begin
            $display("ERROR prod=%0d monedas=%0d -> falta=%b vuelto=%0d (esperado %b, %0d)",
                     p, m, falta, vuelto, esp_falta, esp_vuelto);
            errores++;
        end
    endtask

    task automatic descuenta;
        @(negedge clk); dec_inv = 1;
        @(negedge clk); dec_inv = 0;
        @(negedge clk);
    endtask

    initial begin
        reset = 1; prod_sel = 0; in_coins = 0;
        carga_precio = 0; carga_monto = 0; calcula_vuelto = 0; dec_inv = 0;
        repeat (3) @(negedge clk); reset = 0; repeat (2) @(negedge clk);

        // pago exacto, sobrepago y pago insuficiente
        calcula(2'b11, 4'd4, 0, 10'd0);      // C: 400 - 400
        calcula(2'b01, 4'd2, 0, 10'd50);     // A: 200 - 150
        calcula(2'b10, 4'd3, 0, 10'd25);     // B: 300 - 275
        calcula(2'b11, 4'd3, 1, 10'd0);      // C: 300 - 400 < 0
        calcula(2'b01, 4'd0, 1, 10'd0);      // A con 0 monedas
        calcula(2'b01, 4'd9, 0, 10'd750);    // el mayor vuelto posible: 900 - 150
        calcula(2'b11, 4'd0, 1, 10'd0);      // el mayor faltante posible: -400

        // inventario: 3 unidades de A y luego agotado
        prod_sel = 2'b01; in_coins = 4'd2;
        @(negedge clk); carga_precio = 1; @(negedge clk); carga_precio = 0; @(negedge clk);
        if (agotado !== 1'b0 || agotado_A !== 1'b0) begin $display("ERROR A no debe estar agotado al inicio"); errores++; end
        else $display("OK    inventario inicial de A = 3");
        descuenta; descuenta;
        if (agotado_A !== 1'b0) begin $display("ERROR A agotado con 1 unidad"); errores++; end
        else $display("OK    A con 1 unidad no esta agotado");
        descuenta;
        if (agotado !== 1'b1 || agotado_A !== 1'b1) begin $display("ERROR A debia quedar agotado"); errores++; end
        else $display("OK    A agotado tras 3 ventas");
        if (agotado_B !== 1'b0 || agotado_C !== 1'b0) begin $display("ERROR B o C agotados"); errores++; end
        else $display("OK    B y C intactos");

        // el reset restaura el inventario
        reset = 1; repeat (2) @(negedge clk); reset = 0; @(negedge clk);
        if (agotado_A !== 1'b0) begin $display("ERROR reset no restauro el inventario"); errores++; end
        else $display("OK    reset restaura el inventario");

        if (errores == 0) $display("TODO OK");
        else              $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

    initial begin
        $dumpfile("datapath_vending_tb.vcd");
        $dumpvars(0, datapath_vending_tb);
    end

endmodule
