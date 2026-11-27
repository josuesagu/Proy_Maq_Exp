// Subsistema aritmético (4.3): precio, crédito, resta con signo e inventario.
// La FSM manda las órdenes (carga_precio, carga_monto, calcula_vuelto, dec_inv); aquí se mueven los datos.
//
// Ancho de datos: crédito - precio va de -400 (0 monedas, C) a +750 (9 monedas, A).
// Hacen falta 11 bits con signo (rango -1024 a +1023). El bit 10 es el signo.
// "Alcanza el crédito" sale de ese signo, no de un comparador: falta = 1 si la resta es negativa.
module datapath_vending (
    input  logic        clk, reset,
    input  logic [1:0]  prod_sel,
    input  logic [3:0]  in_coins,
    input  logic        carga_precio, carga_monto, calcula_vuelto, dec_inv,
    output logic        falta,              // 1 = crédito menor que el precio
    output logic        agotado,            // 1 = producto elegido sin existencias
    output logic [1:0]  prod_actual,        // producto de la transacción en curso
    output logic [9:0]  vuelto,             // cambio en colones (0 si falta)
    output logic        agotado_A, agotado_B, agotado_C
);

    logic [10:0] precio_reg;                // 11 bits, positivo
    logic [10:0] credito_reg;
    logic [10:0] dif_reg;                   // crédito - precio, complemento a 2
    logic [1:0]  inv_a, inv_b, inv_c;       // inventario, 3 unidades al inicio
    logic [10:0] credito_next;              // monedas x 100 = (m<<6)+(m<<5)+(m<<2)

    assign credito_next = ({7'b0, in_coins} << 6) + ({7'b0, in_coins} << 5) + ({7'b0, in_coins} << 2);

    // Precio, crédito y producto
    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            prod_actual <= 2'b00;
            precio_reg  <= 11'd0;
            credito_reg <= 11'd0;
        end
        else begin
            if (carga_precio) begin
                prod_actual <= prod_sel;
                case (prod_sel)
                    2'b01:   precio_reg <= 11'd150;   // A
                    2'b10:   precio_reg <= 11'd275;   // B
                    2'b11:   precio_reg <= 11'd400;   // C
                    default: precio_reg <= 11'd0;
                endcase
            end
            if (carga_monto) credito_reg <= credito_next;
        end

    // Resta registrada: crédito + ~precio + 1. El signo es válido un ciclo después de calcula_vuelto.
    always_ff @(posedge clk, posedge reset)
        if (reset)               dif_reg <= 11'd0;
        else if (calcula_vuelto) dif_reg <= credito_reg + ~precio_reg + 11'd1;

    assign falta  = dif_reg[10];
    assign vuelto = dif_reg[10] ? 10'd0 : dif_reg[9:0];

    // Inventario: el reset (S1) lo restaura a 3; restart NO pasa por aquí
    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            inv_a <= 2'd3;
            inv_b <= 2'd3;
            inv_c <= 2'd3;
        end
        else if (dec_inv) begin
            case (prod_actual)
                2'b01:   inv_a <= inv_a - 2'd1;
                2'b10:   inv_b <= inv_b - 2'd1;
                2'b11:   inv_c <= inv_c - 2'd1;
                default: ;
            endcase
        end

    assign agotado_A = (inv_a == 2'd0);
    assign agotado_B = (inv_b == 2'd0);
    assign agotado_C = (inv_c == 2'd0);

    // Agotado del producto de la transacción
    always_comb begin
        agotado = 1'b0;                       // por defecto
        case (prod_actual)
            2'b01:   agotado = agotado_A;
            2'b10:   agotado = agotado_B;
            2'b11:   agotado = agotado_C;
            default: agotado = 1'b0;
        endcase
    end

endmodule
