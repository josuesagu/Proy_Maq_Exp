// Testbench de la FSM sola: se manejan falta/agotado a mano y se revisan las salidas Moore.
`timescale 1ns/1ps
module fsm_vending_tb;

    logic clk = 0, reset, start, restart, falta, agotado, fin_timer;
    logic carga_precio, carga_monto, calcula_vuelto, dec_inv, entrega, devuelve;
    int   errores = 0;

    fsm_vending dut (.*);

    always #18.52 clk = ~clk;

    task automatic chequea(input string nombre, input logic [4:0] esperado);
        logic [4:0] real_;
        real_ = {carga_precio, calcula_vuelto, dec_inv, entrega, devuelve};
        if (real_ === esperado) $display("OK    %s", nombre);
        else begin $display("ERROR %s: salidas=%b esperado=%b", nombre, real_, esperado); errores++; end
    endtask

    // Orden: {carga, calcula, dec_inv, entrega, devuelve}
    initial begin
        reset = 1; start = 0; restart = 0; falta = 0; agotado = 0; fin_timer = 0;
        repeat (2) @(negedge clk); reset = 0;
        chequea("REPOSO sin salidas", 5'b00000);

        // camino de entrega
        start = 1; @(negedge clk); start = 0; chequea("CARGA", 5'b10000);
        @(negedge clk); chequea("CALCULO", 5'b01000);
        @(negedge clk); chequea("EVALUA sin salidas", 5'b00000);
        @(negedge clk); chequea("DEC_INV", 5'b00100);
        @(negedge clk); chequea("ENTREGADO", 5'b00010);
        @(negedge clk); chequea("ENTREGADO espera restart", 5'b00010);
        restart = 1; @(negedge clk); restart = 0; chequea("vuelve a REPOSO", 5'b00000);

        // camino de devolucion por falta
        falta = 1;
        start = 1; @(negedge clk); start = 0; @(negedge clk); @(negedge clk);
        @(negedge clk); chequea("DEVOLUCION por falta", 5'b00001);
        @(negedge clk); chequea("DEVOLUCION espera timer", 5'b00001);
        fin_timer = 1; @(negedge clk); fin_timer = 0; chequea("fin_timer -> REPOSO", 5'b00000);

        // devolucion por agotado
        falta = 0; agotado = 1;
        start = 1; @(negedge clk); start = 0; @(negedge clk); @(negedge clk);
        @(negedge clk); chequea("DEVOLUCION por agotado", 5'b00001);
        fin_timer = 1; @(negedge clk); fin_timer = 0;

        if (errores == 0) $display("TODO OK"); else $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

    initial begin
        $dumpfile("fsm_vending_tb.vcd");
        $dumpvars(0, fsm_vending_tb);
    end

endmodule
