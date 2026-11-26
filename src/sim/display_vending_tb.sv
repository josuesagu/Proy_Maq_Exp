// Testbench del display extra: revisa el protocolo (producto, monedas, vuelto, devolución).
`timescale 1ns/1ps
module display_vending_tb;

    logic [1:0] prod_sel, prod_actual;
    logic [3:0] in_coins;
    logic [9:0] vuelto;
    logic       entrega, devuelve;
    logic [3:0] hex3, hex2, hex1, hex0, blank;
    int         errores = 0;

    display_vending_src dut (.*);

    task automatic chequea(input string nombre, input logic [3:0] e3, e2, e1, e0, input logic [3:0] eblank);
        #1;
        // un dígito apagado no se compara (su valor no importa)
        if (blank === eblank
            && (blank[3] || hex3 === e3) && (blank[2] || hex2 === e2)
            && (blank[1] || hex1 === e1) && (blank[0] || hex0 === e0))
            $display("OK    %s", nombre);
        else begin
            $display("ERROR %s: %h %h %h %h blank=%b", nombre, hex3, hex2, hex1, hex0, blank);
            errores++;
        end
    endtask

    initial begin
        prod_sel = 0; prod_actual = 0; in_coins = 0; vuelto = 0; entrega = 0; devuelve = 0;
        chequea("sin producto: solo monedas", 0, 0, 0, 0, 4'b1110);

        prod_sel = 2'b01; in_coins = 4'd2;
        chequea("A con 2 monedas", 4'hA, 0, 0, 4'd2, 4'b0110);
        prod_sel = 2'b10;
        chequea("B con 2 monedas", 4'hB, 0, 0, 4'd2, 4'b0110);
        prod_sel = 2'b11;
        chequea("C con 2 monedas", 4'hC, 0, 0, 4'd2, 4'b0110);

        prod_actual = 2'b01; prod_sel = 2'b11; entrega = 1; vuelto = 10'd50;
        chequea("entrega A, vuelto 050 (ignora prod_sel)", 4'hA, 4'd0, 4'd5, 4'd0, 4'b0000);
        vuelto = 10'd750;
        chequea("entrega A, vuelto 750", 4'hA, 4'd7, 4'd5, 4'd0, 4'b0000);

        entrega = 0; devuelve = 1; in_coins = 4'd3; prod_actual = 2'b11;
        chequea("devolucion C: d, 3 monedas", 4'hC, 4'hD, 0, 4'd3, 4'b0010);

        if (errores == 0) $display("TODO OK"); else $display("TERMINO CON %0d ERRORES", errores);
        $finish;
    end

endmodule
