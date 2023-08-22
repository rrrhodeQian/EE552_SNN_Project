`timescale 1ns/100ps

import SystemVerilogCSP::*;

module ifmap_tb (
    interface ifmap_addr,
    interface ifmap_data,
    interface timestep,
    interface load_done,
    interface ifmap_out
);
    parameter ADDR_WIDTH = 10;
    parameter DEPTH_I = 25;
    parameter PACK_WIDTH = 64;

    logic i1_data, i2_data;
    logic [1:0] ts = 1;
    logic [ADDR_WIDTH-1:0] i1_addr = 0, i2_addr=0;
    logic [PACK_WIDTH-1:0] out_data [21*5-1:0];

    integer fpi_i1, fpi_i2, status;

    // watchdog timer
    initial begin
        #100000000;
        $display("*** Stopped by watchdog timer ***");
        $finish;
    end

    initial begin
        // sending values to M module
        fpi_i1 = $fopen("C:\\EE552_project\\ifmap1.txt","r");
        fpi_i2 = $fopen("C:\\EE552_project\\ifmap2.txt", "r");

        if(!fpi_i1 || !fpi_i2)
        begin
            $display("A file cannot be opened!");
            $finish;
        end

        else begin
    
        // sending ifmap 1 (timestep1)
            for(integer i=0; i<DEPTH_I*DEPTH_I; i++) begin
	            if (!$feof(fpi_i1)) begin
	                status = $fscanf(fpi_i1,"%d\n", i1_data);
	                $display("Ifmap1 data read:%d", i1_data);
     	            timestep.Send(ts);
	                ifmap_addr.Send(i1_addr);
	                ifmap_data.Send(i1_data);
                    i1_addr++;
	            end 
            end

	        ts++;

        // sending ifmap 2 (timestep2)
	        for(integer i=0; i<DEPTH_I*DEPTH_I; i++) begin
	            if (!$feof(fpi_i2)) begin
	                status = $fscanf(fpi_i2,"%d\n", i2_data);
	                $display("Ifmap2 data read:%d", i2_data);
	                timestep.Send(ts);
	                ifmap_addr.Send(i2_addr);
	                ifmap_data.Send(i2_data);
                    i2_addr++;
	            end
            end
        end

        //Finish sending the matrix values
        load_done.Send(1); 
        // $fdisplay(fpt,"%m sent load_done token at %t",$realtime);
        $display("%m sent load_done token at %t",$realtime);

        for (int j = 0; j < 21 * 5; j++) begin
            ifmap_out.Receive(out_data[j]);
        end
        $display("%m ifmap sent done at %t",$realtime);
    end
endmodule

module testbench;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(64)) intf[4:0] ();

    ifmap ifm(.ifmap_addr(intf[0]), .ifmap_data(intf[1]), .timestep(intf[2]), .load_done(intf[3]), .ifmap_out(intf[4]));
    ifmap_tb ifm_tb(.ifmap_addr(intf[0]), .ifmap_data(intf[1]), .timestep(intf[2]), .load_done(intf[3]), .ifmap_out(intf[4]));
endmodule