`timescale 1ns/100ps

import SystemVerilogCSP::*;

//pe testbench
module pe_tb(
  interface filter_in,
  interface ifmap_in,
  interface psum_out
);

  parameter WIDTH = 8;
  parameter WIDTH_O = 13;
  parameter DEPTH_I = 25;
//  parameter ADDR_I = 5;
  parameter DEPTH_F = 5;
  parameter DEPTH_O = 21;
//  parameter ADDR_F = 3;
  parameter PACKET_D_WIDTH = 40;
  parameter DIN_WIDTH_I = 25;
 
 logic d;
 logic [DIN_WIDTH_I-1:0] data_ifmap_in;
 logic [PACKET_D_WIDTH-1:0] data_filter_in;
//  logic data_ifmap [DEPTH_I-1:0];
//  logic [ADDR_F-1:0] addr_filter = 0;
//  logic [ADDR_I-1:0] addr_ifmap = 0;
 logic [PACKET_D_WIDTH-1:0] psum_o;
 integer fpo, fpi_f, fpi_i, status, don_e = 0;
 
// watchdog timer
 initial begin
 #1000000;
 $display("*** Stopped by watchdog timer ***");
 $stop;
 end
 
// main execution
 initial begin
// loading memories
  #100;
   fpi_f = $fopen("C:\\EE552_project\\filter.txt","r");
   fpi_i = $fopen("C:\\EE552_project\\ifmap.txt","r");
   fpo = $fopen("pe_tb.dump");
   if(!fpi_f || !fpi_i)
   begin
       $display("A file cannot be opened!");
       $stop;
   end
        // load one row of filter value
	      if(!$feof(fpi_f)) begin
	        status = $fscanf(fpi_f,"%b\n", data_filter_in);
	        $display("fpf data read:%b", data_filter_in);
	        filter_in.Send(data_filter_in); 
	      end
    
    //load ifmap value
    for (int j = 0; j < 25; j ++) begin
	    if (!$feof(fpi_i)) begin
	      status = $fscanf(fpi_i,"%b\n", data_ifmap_in);
	      $display("fpi data read:%b", data_ifmap_in);
	      // ifmap_addr.Send(addr_ifmap);
	      ifmap_in.Send(data_ifmap_in); 
	      // $display("ifmap memory: mem[%d]= %d",addr_ifmap, data_ifmap);
	      // addr_ifmap++;

        //receive psum out
        for(integer i=0; i<DEPTH_O; i++) begin
          psum_out.Receive(psum_o);
          $fdisplay(fpo,"psum_out O1%d: %d",i+1,psum_o); 
          $display("%m psum O1%0d: %d received at %t",i, psum_o, $time);
        end
	    end
    end
    #800;
    $stop;
 end

// waiting for done
  // done.Receive(don_e);
  // $display("%m done received. ending simulation at %t",$time);

//-------------uncomment for filter loading test-----------//
//feed with second row of filter data
  // if(!$feof(fpi_f)) begin
  //   status = $fscanf(fpi_f,"%b\n", data_filter_in);
  //   $display("fpf data read:%b", data_filter_in);
  //   filter_in.Send(data_filter_in); 
  // end 
//----------------------------------------------------------//
	   

endmodule

//testbench
module testbench;
  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(40)) intf_2 ();
  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(40)) intf_1 ();
  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(40)) intf_0 ();

  parameter WIDTH = 8;
  parameter WIDTH_O = 13;
  parameter DEPTH_I = 25;
//  parameter ADDR_I = 5;
  parameter DEPTH_F = 5;
  parameter DEPTH_O = 21;
//  parameter ADDR_F = 3;
  parameter PACKET_D_WIDTH = 40;
  parameter DIN_WIDTH_I = 25;
 
//pe_tb
pe_tb petb(.filter_in(intf_2), /*.filter_addr(intf[6]),*/ .ifmap_in(intf_1),
  /*.ifmap_addr(intf[4]), .psum_in(intf[2]), .start(intf[0]), .done(intf[1]),*/ .psum_out(intf_0));

//DUT (pe)
 pe pe_i(.filter_in(intf_2), /*.filter_addr(intf[6]),*/ .ifmap_in(intf_1),
  /*.ifmap_addr(intf[4]), .psum_in(intf[2]), .start(intf[0]), .done(intf[1]),*/ .psum_out(intf_0));
 
endmodule
 

