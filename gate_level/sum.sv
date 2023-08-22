`timescale 1ps/1ps
`define WIDTH_IN 8
`define WIDTH_OUT 13
`define FL 2
`define BL 2

module sum (
    input logic L1_req,
    input logic L2_req,
    input logic [`WIDTH_IN-1:0] L1_data,
    input logic [`WIDTH_IN-1:0] L2_data,
    input logic R_ack,
    output logic L1_ack,
    output logic L2_ack,
    output logic R_req,
    output logic [`WIDTH_OUT-1:0] R_data
);
    logic w1, w2, w3;
    logic [`WIDTH_OUT-1:0] w4;

    c_element ce1(.inPort1(L1_req), .inPort2(L2_req), .outPort(w2));
    inverter inv1(.inPort(R_ack), .outPort(w1));
    c_element ce2(.inPort1(w2), .inPort2(w1), .outPort(w3));
    adder ad1(.inPort1(L1_data), .inPort2(L2_data), .outPort(w4));
    latch lt1(.inPort(w4), .clk(w3), .outPort(R_data));

    assign #`BL L1_ack = w3;
    assign #`BL L2_ack = w3;
    assign #`FL R_req  = w3;

    initial begin
        w3 = 0;
    end
endmodule