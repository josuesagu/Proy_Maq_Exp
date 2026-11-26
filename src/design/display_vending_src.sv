// Fuente del display extra (25 %): decide qué se ve en cada dígito según la etapa de la compra.
// Protocolo del grupo (4 dígitos, de izquierda a derecha):
//   dígito 3: producto A, b o C (apagado si no hay producto elegido)
//   reposo (eligiendo):  [producto] [  ] [  ] [monedas]       ej.  A __ __ 2
//   entrega:             [producto] [vuelto de 3 dígitos]      ej.  A 0 5 0
//   devolución:          [producto] [d] [  ] [monedas]        ej.  A  d __ 2   (d = devuelto)
// Usa bcd_converter del profesor para pasar el vuelto de binario a BCD.
// Autor: Josué
module display_vending_src (
    input  logic [1:0] prod_sel,        // producto elegido en el teclado
    input  logic [1:0] prod_actual,     // producto de la transacción en curso
    input  logic [3:0] in_coins,        // monedas de 100
    input  logic [9:0] vuelto,          // vuelto en binario (0-750)
    input  logic       entrega, devuelve,
    output logic [3:0] hex3, hex2, hex1, hex0,
    output logic [3:0] blank            // 1 = ese dígito apagado (bit 3 = dígito izquierdo)
);

    logic [11:0] bcd;                   // {centenas, decenas, unidades} del vuelto
    logic [1:0]  prod;                  // producto que se muestra

    bcd_converter #(.N(10), .M(12)) bcd_unit (
        .input_bin(vuelto),
        .output_bcd(bcd)
    );

    // En una transacción se muestra el producto guardado; si no, el que se está eligiendo
    assign prod = (entrega || devuelve) ? prod_actual : prod_sel;

    always_comb begin
        hex3  = 4'h0;
        hex2  = 4'h0;
        hex1  = 4'h0;
        hex0  = 4'h0;
        blank = 4'b0000;
        case (prod)                      // letra del producto
            2'b01:   hex3 = 4'hA;
            2'b10:   hex3 = 4'hB;        // se ve como "b"
            2'b11:   hex3 = 4'hC;
            default: blank[3] = 1'b1;    // sin producto: dígito apagado
        endcase
        if (entrega) begin               // vuelto
            hex2 = bcd[11:8];
            hex1 = bcd[7:4];
            hex0 = bcd[3:0];
        end
        else if (devuelve) begin         // "d" y las monedas devueltas
            hex2     = 4'hD;
            blank[1] = 1'b1;
            hex0     = in_coins;
        end
        else begin                       // reposo: solo las monedas
            blank[2] = 1'b1;
            blank[1] = 1'b1;
            hex0     = in_coins;
        end
    end

endmodule
