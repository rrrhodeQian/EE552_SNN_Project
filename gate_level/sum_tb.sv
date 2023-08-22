`timescale 1ps/1ps
`define WIDTH_IN 8
`define WIDTH_OUT 13
`define FL 2
`define BL 2

module sum_tb ();
    logic L1_req = 0, L2_req = 0, R_ack = 1, L1_ack, L2_ack, R_req;
    logic [`WIDTH_IN-1:0] L1_data, L2_data;
    logic [`WIDTH_OUT-1:0] R_data;

    sum dut(.L1_req(L1_req), .L2_req(L2_req), .R_ack(R_ack), .L1_ack(L1_ack), .L2_ack(L2_ack), .R_req(R_req), .L1_data(L1_data), .L2_data(L2_data), .R_data(R_data));

    initial begin
        repeat (20) begin
            #2;
            L1_req = ~L1_req;
            L2_req = ~L2_req;
            R_ack = ~R_ack;
        end
    end

    initial begin
        repeat (20) begin
            #4;
            L1_data = $urandom % (2**(`WIDTH_IN-1));
            L2_data = $urandom % (2**(`WIDTH_IN-1));
        end
    end
endmodule