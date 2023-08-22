`timescale 1ns/100ps
import SystemVerilogCSP::*;

module arbiter2_1 (
    interface in1,
    interface in2,
    interface out
);
    parameter PACK_WIDTH = 51;

    logic [PACK_WIDTH-1:0] pack_in;
    logic w;

    always begin
        wait (in1.status != idle || in2.status != idle);

        if (in1.status != idle && in2.status != idle) begin
            w = $urandom % 2; //random number between 0 to 1
        end
        else if (in1.status != idle) begin
            w = 1'b0;
        end
        else begin
            w = 1'b1;
        end

        if (w == 1'b0) begin
            in1.Receive(pack_in);
            out.Send(pack_in);
        end
        else begin
            in2.Receive(pack_in);
            out.Send(pack_in);
        end
    end
endmodule

module arbiter3_1 (
    interface in1,
    interface in2,
    interface in3,
    interface out
);
    parameter PACK_WIDTH = 51;

    logic [PACK_WIDTH-1:0] pack_in;
    logic [1:0] w;

    always begin
        wait (in1.status != idle || in2.status != idle || in3.status != idle);

        if (in1.status != idle && in2.status != idle && in3.status != idle) begin
            w = $urandom % 3; //random number between 0 to 2
        end
        else if (in1.status != idle && in2.status != idle) begin
            w = ($urandom % 2) ? 2'b00 : 2'b01;
        end
        else if (in1.status != idle && in3.status != idle) begin
            w = ($urandom % 2) ? 2'b00 : 2'b10;
        end
        else if (in2.status != idle && in3.status != idle) begin
            w = ($urandom % 2) ? 2'b01 : 2'b10;
        end
        else if (in1.status != idle) begin
            w = 2'b00;
        end
        else if (in2.status != idle) begin
            w = 2'b01;
        end
        else begin
            w = 2'b10;
        end

        if (w == 2'b00) begin
            in1.Receive(pack_in);
            out.Send(pack_in);
        end
        else if (w == 2'b01) begin
            in2.Receive(pack_in);
            out.Send(pack_in);
        end
        else if (w == 2'b10) begin
            in3.Receive(pack_in);
            out.Send(pack_in);
        end
    end
endmodule

module arbiter (
    interface in_up,
    interface in_down,
    interface in_left,
    interface in_right,
    interface in_local,
    interface arb_out //all 51-bit
);
    parameter PACK_WIDTH = 51;
    
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(51)) intf[1:0] ();

    arbiter2_1 ab1 (.in1(in_up), .in2(in_down), .out(intf[0]));
    arbiter3_1 ab2 (.in1(in_left), .in2(in_right), .in3(in_local), .out(intf[1]));
    arbiter2_1 ab3 (.in1(intf[0]), .in2(intf[1]), .out(arb_out));
endmodule