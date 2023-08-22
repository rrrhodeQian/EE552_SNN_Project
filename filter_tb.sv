`timescale 1ns/100ps

import SystemVerilogCSP::*;

module filter_tb (
    interface filter_addr,
    interface filter_data,
    interface load_start,
    interface load_done,
    interface filter_out
);
    parameter ADDR_WIDTH = 5;
    parameter DEPTH_F = 5;
    parameter PACK_WIDTH = 64;
    parameter WIDTH = 8;

    // logic i1_data, i2_data;
    // logic [1:0] ts = 1;
    logic [WIDTH-1:0] f_data;
    logic [ADDR_WIDTH-1:0] f_addr = 0;
    // logic [ADDR_WIDTH-1:0] i1_addr = 0, i2_addr=0;
    logic [PACK_WIDTH-1:0] out_data [DEPTH_F-1:0];

    integer fpi_f, status;

    initial begin
    // sending values to M module
        fpi_f = $fopen("C:\\EE552_project\\filter.txt","r");

        if(!fpi_f) begin
            $display("A file cannot be opened!");
            $finish;
        end

    else begin
	    load_start.Send(1);
	    for(integer i=0; i<(DEPTH_F*DEPTH_F); i++) begin
	        if(!$feof(fpi_f)) begin
	            status = $fscanf(fpi_f,"%d\n", f_data);
	            $display("filter data read:%d", f_data);
	            filter_addr.Send(f_addr);
	            filter_data.Send(f_data); 
	            f_addr++;
	        end
        end
        load_done.Send(1); 
        // $fdisplay(fpt,"%m sent load_done token at %t",$realtime);
        $display("%m sent load_done token at %t",$realtime);
        for (int j = 0; j < DEPTH_F; j++) begin
            filter_out.Receive(out_data[j]);
            $display("filter data out:%d", out_data[39:0]);
        end
        $display("%m filter sent done at %t",$realtime);
    end
    end
endmodule

module testbench;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(64)) intf[4:0] ();

    filter flm(.filter_addr(intf[0]), .filter_data(intf[1]), .load_start(intf[2]), .load_done(intf[3]), .filter_out(intf[4]));
    filter_tb flm_tb(.filter_addr(intf[0]), .filter_data(intf[1]), .load_start(intf[2]), .load_done(intf[3]), .filter_out(intf[4]));
endmodule