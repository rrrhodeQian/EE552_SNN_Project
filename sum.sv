`timescale 1ns/100ps

module sum (
    interface in1,
    interface in2,
    interface out
);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter DEPTH_F = 5;
    parameter PACKET_D_WIDTH = 40;
    parameter DIN_WIDTH_I = 25;
    parameter WIDTH_O = 13;
    parameter ADDR_WIDTH = 5;
    parameter FL = 2;
    parameter BL = 2;

    logic [PACKET_D_WIDTH-1:0] din1;
    logic [PACKET_D_WIDTH-1:0] din2;
    logic [WIDTH_O-1:0] data_in1;
    logic [WIDTH_O-1:0] data_in2;
    logic [WIDTH_O-1:0] sum_result;
    logic [ADDR_WIDTH*2-1:0] addr;
    logic [PACKET_D_WIDTH-1:0] dout;

    always begin
        fork
            in1.Receive(din1);
            // $display("sum %m in1 receive = %b at %t", din1, $realtime);
            in2.Receive(din2);
            // $display("sum %m in2 receive = %b at %t", din2, $realtime);
        join
        #FL;
        data_in1 = din1[WIDTH_O-1:0];
        data_in2 = din2[WIDTH_O-1:0];
        addr = din1[PACKET_D_WIDTH-1:30];
        sum_result = data_in1 + data_in2;//calculate sum result
        dout = {addr, 17'b0, sum_result};//wrap up output data
        out.Send(dout);
        // $display("sum %m out send = %b at %t", dout, $realtime);
        $display("data_in1 = %d, data_in2 = %d, addr1 = %d, addr2 = %d, sum_result = %d at time = %t", data_in1, data_in2, din1[PACKET_D_WIDTH-1:30], din2[PACKET_D_WIDTH-1:30], sum_result, $realtime);

        #BL;
    end
endmodule