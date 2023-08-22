`timescale 1ns/100ps
import SystemVerilogCSP::*;

module ifmap_mem (
    interface ifmap_addr,
    interface ifmap_data,
    interface bank_sel,
    interface ifmap_addr_out,
    interface ifmap_data_out
);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    parameter ADDR_WIDTH = 10;
    parameter FL = 12;

    logic mem0 [DEPTH_I*DEPTH_I-1:0];
    logic mem1 [DEPTH_I*DEPTH_I-1:0];
    logic [ADDR_WIDTH-1:0] addr_in, addr_out;
    logic din, dout, bank;

    always begin
        fork
            bank_sel.Receive(bank);
            ifmap_addr.Receive(addr_in);
            ifmap_data.Receive(din);
        join
        #FL;
        if (bank == 1'b0) begin
            mem0[addr_in] = din;
        end
        else begin
            mem1[addr_in] = din;
        end
    end

    always begin
        fork
            bank_sel.Receive(bank);
            ifmap_addr_out.Receive(addr_out);
        join
        if (bank == 1'b0) begin
            dout = mem0[addr_out];
        end
        else begin
            dout = mem1[addr_out];
        end
        ifmap_data_out.Send(dout);
    end
endmodule

module ifmap_control (
    interface timestep,
    // interface load_start,
    interface load_done,
    interface bank_sel,
    interface ifmap_addr_out,
    interface pack_start
);
    parameter ADDR_WIDTH = 7;
    parameter DEPTH_I = 25;
    parameter no_rows = 21;

    logic [1:0] ts;
    logic /*start,*/ done;

    always begin
        timestep.Receive(ts);
        if (ts == 2'b01) begin
            bank_sel.Send(0);
        end
        else begin
            bank_sel.Send(1);
        end
    end

    always begin
        load_done.Receive(done);
        pack_start.Send(1);
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < no_rows; j++) begin
                for (int index = 0; index < 5 * DEPTH_I; index++) begin
                bank_sel.Send(i);
                ifmap_addr_out.Send(j * DEPTH_I + index);
                end
            end
        end

    end
endmodule

module ifmap_pack (
    interface pack_start,
    // interface filter_sent,
    interface data_in,
    interface ifmap_out
);
    parameter PACKET_D_WIDTH = 40;
    parameter PACK_WIDTH = 44;
    parameter DEPTH_I = 25;
    parameter no_rows = 21;
    parameter FL = 12;
    parameter BL = 4;

    logic start;
    logic din;
    logic [PACKET_D_WIDTH-1:0] pack_data;
    logic [PACK_WIDTH-1:0] pack_out;
    logic [3:0] dest_addr;
    // logic filter_done;

    always begin
        pack_start.Receive(start);
        // filter_sent.Receive(filter_done);
        // #FL;
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < no_rows; j++) begin
                for (int counter = 0; counter < 5; counter++) begin
                    pack_out = 'b0;
                    pack_data = 'b0;
                    for (int num = 0; num < DEPTH_I; num++) begin
                        data_in.Receive(din);
                        pack_data[num] = din;
                    end
                    dest_addr = counter;
                    pack_out = {dest_addr, pack_data};
                    ifmap_out.Send(pack_out);
                    $display("ifmap %m ifmap_out = %b, addr row: %d ,at %t", pack_out, dest_addr, $realtime);
                    #BL;
                end
            end
        end
    end
endmodule

module ifmap (
    interface timestep,
    interface load_done,
    interface ifmap_addr,
    interface ifmap_data,
    interface ifmap_out
);
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(10)) intf[3:0] ();

    ifmap_mem im(.ifmap_addr(ifmap_addr), .ifmap_data(ifmap_data), .bank_sel(intf[0]), .ifmap_addr_out(intf[1]), .ifmap_data_out(intf[2]));
    ifmap_control ctrl(.timestep(timestep), .load_done(load_done), .bank_sel(intf[0]), .ifmap_addr_out(intf[1]), .pack_start(intf[3]));
    ifmap_pack pck(.pack_start(intf[3]), .data_in(intf[2]), .ifmap_out(ifmap_out));
endmodule