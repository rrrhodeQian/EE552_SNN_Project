`timescale 1ns/100ps
import SystemVerilogCSP::*;

module router_t2 (
    interface in_left,
    interface out_up,
    interface out_right
);
    parameter PACK_WIDTH = 44;
    parameter PACKET_D_WIDTH = 40;
    parameter logic [3:0] LOCAL_ADDR = 4'b0000;
    parameter FL = 1;
    parameter BL = 1;
    
    logic [PACK_WIDTH-1:0] pack_in;
    // logic [PACK_WIDTH-1:0] pack_in_down;
    logic [3:0] dest_addr;

    always begin
        in_left.Receive(pack_in);
        #FL;

        dest_addr = pack_in[43:40];
        if (dest_addr[2:0] == LOCAL_ADDR[2:0]) begin //destination x = local x
            out_up.Send(pack_in);
            // $display("router %m out_up sent = %b at %t", pack_in, $realtime);
        end
        else begin
            out_right.Send(pack_in);
            // $display("router %m right sent = %b at %t", pack_in, $realtime);
        end

        #BL;
    end
endmodule