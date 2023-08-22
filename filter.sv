`timescale 1ns/100ps
import SystemVerilogCSP::*;

module filter_mem (
    // interface load_start,
    interface filter_data, //8-bit
    interface filter_addr, //5-bit
    interface filter_data_out, //8-bit
    interface filter_addr_out //5-bit
);

    parameter WIDTH = 8;
    parameter DEPTH_F = 5;
    parameter ADDR_WIDTH = 5;
    parameter FL = 12;
    // parameter BL = 4;

    logic [WIDTH-1:0] mem_array [DEPTH_F*DEPTH_F-1:0];
    logic [ADDR_WIDTH-1:0] addr_in, addr_out;
    logic [WIDTH-1:0] din, dout;

    always begin
        fork
            filter_addr.Receive(addr_in);
            filter_data.Receive(din);
        join
        #FL;
        mem_array[addr_in] = din;
    end

    always begin
        filter_addr_out.Receive(addr_out);
        dout = mem_array[addr_out];
        filter_data_out.Send(dout);
    end
endmodule

module filter_control (
    interface load_start,
    interface load_done,
    interface pack_start,
    interface filter_addr_out //5-bit
);
    parameter ADDR_WIDTH = 5;
    parameter DEPTH_F = 5;

    logic start, done;
    // logic [ADDR_WIDTH-1:0] addr_out;

    always begin
        load_start.Receive(start);
        load_done.Receive(done);
        pack_start.Send(1);
        for (int i = 0; i < DEPTH_F*DEPTH_F; i ++) begin
            filter_addr_out.Send(i);
        end
    end
endmodule

module filter_pack (
    interface pack_start,
    interface data_in, //8-bit
    interface filter_out //44-bit
);
    parameter WIDTH = 8;
    parameter PACKET_D_WIDTH = 40;
    parameter PACK_WIDTH = 44;
    parameter DEPTH_F = 5;
    parameter BL = 4;
    
    logic [WIDTH-1:0] din;
    logic [PACKET_D_WIDTH-1:0] pack_data;
    logic [PACK_WIDTH-1:0] pack_out;
    logic [3:0] dest_addr;
    logic st;

    always begin
        pack_start.Receive(st);
        for (int i = 0; i < DEPTH_F; i++) begin
            pack_out = 'b0;
            // for (int j = 0; j < DEPTH_F; j++) begin
                data_in.Receive(din);
                pack_data[7:0] = din;
                data_in.Receive(din);
                pack_data[15:8] = din;
                data_in.Receive(din);
                pack_data[23:16] = din;
                data_in.Receive(din);
                pack_data[31:24] = din;
                data_in.Receive(din);
                pack_data[39:32] = din;
            // end
            dest_addr = i;
            pack_out = {dest_addr, pack_data};
            filter_out.Send(pack_out);
            // $display("filter %m filter_out = %b at %t", pack_out, $realtime);
            #BL;
        end
        // filter_sent.Send(1);
    end
endmodule

module filter (
    interface filter_addr,
    interface filter_data,
    interface load_start,
    interface load_done,
    interface filter_out
);
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) intf[2:0] ();

    filter_mem fm(.filter_addr(filter_addr), .filter_data(filter_data), .filter_addr_out(intf[0]), .filter_data_out(intf[1]));
    filter_control ctrl(.load_start(load_start), .load_done(load_done), .pack_start(intf[2]), .filter_addr_out(intf[0]));
    filter_pack pck(.pack_start(intf[2]), .data_in(intf[1]), .filter_out(filter_out));

endmodule