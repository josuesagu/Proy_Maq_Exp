// Temporizador de la devolución de monedas: da un pulso fin_timer tras CICLOS ciclos con activo = 1.
// 27 MHz x 2 s = 54 000 000 ciclos. En simulación se baja CICLOS con un parámetro.
// Autor: Josué
module temporizador_devolucion #(parameter CICLOS = 54_000_000) (
    input  logic clk, reset,
    input  logic activo,          // 1 mientras la FSM está en DEVOLUCION
    output logic fin_timer        // pulso de 1 ciclo
);

    logic [25:0] cuenta;          // 2^26 = 67 M > 54 M

    always_ff @(posedge clk, posedge reset)
        if (reset)                 cuenta <= 26'd0;
        else if (!activo)          cuenta <= 26'd0;
        else if (fin_timer)        cuenta <= 26'd0;
        else                       cuenta <= cuenta + 26'd1;

    assign fin_timer = activo && (cuenta == CICLOS - 1);

endmodule
