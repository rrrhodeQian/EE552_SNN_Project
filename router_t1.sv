`timescale 1ns/100ps
import SystemVerilogCSP::*;

module router_t1 (
    interface in_left,
    interface in_down,
    interface out_right,
    interface router_out1,
    interface router_out2
);
    parameter PACK_WIDTH = 44;
    parameter PACKET_D_WIDTH = 40;
    parameter logic [3:0] LOCAL_ADDR = 4'b0000;
    parameter FL = 1;
    parameter BL = 1;
    
    logic [PACK_WIDTH-1:0] pack_in_left;
    logic [PACK_WIDTH-1:0] pack_in_down;
    logic [3:0] dest_addr;

    always begin
        in_left.Receive(pack_in_left);
        #FL;

        dest_addr = pack_in_left[43:40];
        if (dest_addr == LOCAL_ADDR) begin //destination addr = local addr
            router_out2.Send(pack_in_left[PACKET_D_WIDTH-1:0]);
            // $display("router %m r2 sent = %b at %t", pack_in_left[PACKET_D_WIDTH-1:0], $realtime);
        end
        //     else if (dest_addr[3] < LOCAL_ADDR[3]) begin
        //         out_up.Send(pack_in);
        //         $display("router %m up sent = %b at %t", pack_in, $realtime);
        //     end
        //     else begin
        //         out_down.Send(pack_in);
        //         $display("router %m down sent = %b at %t", pack_in, $realtime);
        //     end
        // end

        // else if (dest_addr[2:0] > LOCAL_ADDR[2:0]) begin //destination x > local x
        //     out_right.Send(pack_in);
        //     $display("router %m right sent = %b at %t", pack_in, $realtime);
        // end
        else begin
            out_right.Send(pack_in_left);
            // $display("router %m right sent = %b at %t", pack_in_left, $realtime);
        end

        #BL;
    end

    always begin
        in_down.Receive(pack_in_down);
        #FL;

        router_out1.Send(pack_in_down[PACKET_D_WIDTH-1:0]);
        // $display("router %m r1 sent = %b at %t", pack_in_down, $realtime);
        #BL;
    end
endmodule