`timescale 1ps/1ps
`define WIDTH_IN 8
`define WIDTH_OUT 13

module c_element (
    input inPort1,
    input inPort2,
    output logic outPort
);
    always begin
        wait(inPort1 && inPort2);
            outPort = 1'b1;
        wait(!inPort1 && !inPort2);
            outPort = 1'b0;
    end
endmodule

module inverter (
    input inPort,
    output outPort
);
    assign outPort = ~inPort;
endmodule

module adder (
    input logic [`WIDTH_IN-1:0] inPort1,
    input logic [`WIDTH_IN-1:0] inPort2,
    output logic [`WIDTH_OUT-1:0] outPort
);
    assign outPort = {5'b0, inPort1 + inPort2};
endmodule

module latch (
    input [`WIDTH_IN-1:0] inPort,
    input clk,
    output logic [`WIDTH_OUT-1:0] outPort
);
    always @(*) begin
        if (clk)
        outPort <= inPort;
    end
endmodule