// Testbench de lectura_teclas: se simulan teclas directamente (b_presionado + s_aviso).
`timescale 1ns/1ps
module lectura_teclas_tb;

    logic       clk = 0, reset, s_aviso;
    logic [4:0] b_presionado;
    logic [1:0] prod_sel;
    logic [3:0] in_coins;
    logic       start, restart;
    int         errores = 0;

    lectura_teclas dut (.*);

    always #18.52 clk = ~clk;

    task automatic tecla(input logic [4:0] k);
        @(negedge clk); b_presionado = k; s_aviso = 1;
        @(negedge clk); s_aviso = 0;
    endtask

    task automatic chequea(input string nombre, input logic [1:0] p, input logic [3:0] c);
        if (prod_sel === p && in_coins === c) $display("OK    %s", nombre);
        else begin $display("ERROR %s: prod=%b coins=%0d", nombre, prod_sel, in_coins); errores++; end
    endtask

    initial begin
        reset = 1; s_aviso = 0; b_presionado = 5'b10000;
        repeat (2) @(negedge clk); reset = 0;

        tecla(5'd13); @(negedge clk);
        if (start !== 1'b0) begin $display("ERROR start sin producto"); errores++; end
        else $display("OK    D sin producto no hace start");

        tecla(5'd12); chequea("C -> 11", 2'b11, 4'd0);
        tecla(5'd4);  chequea("4 monedas", 2'b11, 4'd4);
        tecla(5'd3);  chequea("queda la ultima: 3", 2'b11, 4'd3);
        tecla(5'd10); chequea("A -> 01", 2'b01, 4'd3);
        tecla(5'd11); chequea("B -> 10", 2'b10, 4'd3);

        @(negedge clk); b_presionado = 5'd13; s_aviso = 1;
        @(negedge clk); s_aviso = 0;
        if (start === 1'b1) $display("OK    D con producto da start");
        else begin $display("ERROR no hubo start"); errores++; end
        @(negedge clk);
        if (start !== 1'b0) begin $display("ERROR start dura mas de 1 ciclo"); errores++; end

        @(negedge clk); b_presionado = 5'd14; s_aviso = 1;
        @(negedge clk); s_aviso = 0;
        if (restart === 1'b1) $display("OK    * da restart");
        else begin $display("ERROR no hubo restart"); errores++; end
        @(negedge clk);
        chequea("* borra la seleccion", 2'b00, 4'd0);

        tecla(5'd15); chequea("# sin funcion", 2'b00, 4'd0);

        if (errores == 0) $display("TODO OK"); else $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

    initial begin
        $dumpfile("lectura_teclas_tb.vcd");
        $dumpvars(0, lectura_teclas_tb);
    end

endmodule
