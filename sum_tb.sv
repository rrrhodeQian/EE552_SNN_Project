`timescale 1ns/100ps
import SystemVerilogCSP::*;

//sum testbench
module sum_tb(
  interface to_in1,
  interface to_in2,
  interface from_out
);

    parameter WIDTH = 8;
    parameter WIDTH_O = 13;
    parameter DEPTH_I = 25;
    parameter DEPTH_F = 5;
    parameter DEPTH_O = 21;
    parameter PACKET_D_WIDTH = 40;
    logic [PACKET_D_WIDTH-1:0] data1;
    logic [PACKET_D_WIDTH-1:0] data2;
    logic [PACKET_D_WIDTH-1:0] dout;
    integer fpo, fpi_1, fpi_2, status, don_e = 0, i = 0;
 
// watchdog timer
    initial begin
        #1000;
        $display("*** Stopped by watchdog timer ***");
        $stop;
    end
 
// main execution
    initial begin
// loading memories
        #100;
        fpi_1 = $fopen("C:\\EE552_project\\data1.txt","r");
        fpi_2 = $fopen("C:\\EE552_project\\data2.txt","r");
        fpo = $fopen("C:\\EE552_project\\sum_tb.dump");
        if(!fpi_1 || !fpi_2)
        begin
            $display("A file cannot be opened!");
            $stop;
        end
    
    //load ifmap value
    for (int j = 0; j < 10; j ++) begin
        if(!$feof(fpi_1)) begin
	        status = $fscanf(fpi_1,"%b\n", data1);
	        $display("fp1 data read:%b", data1);
	        to_in1.Send(data1); 
	    end

	    if (!$feof(fpi_2)) begin
	        status = $fscanf(fpi_2,"%b\n", data2);
	        $display("fp2 data read:%b", data2);
	        to_in2.Send(data2); 
        end

        //receive data out
        // for(integer i=0; i<DEPTH_O; i++) begin
            i += 1;
            from_out.Receive(dout);
            $fdisplay(fpo,"data_out O1%d: %d",i+1,dout); 
            $display("%m data_out O1%0d: %d received at %t",i, dout, $time);
        // end
    end
    #800;
    $stop;
end
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
 
//sum_tb
sum_tb sumtb(.to_in1(intf_2), .to_in2(intf_1), .from_out(intf_0));

//DUT (sum)
sum sum_i(.in1(intf_2), .in2(intf_1), .out(intf_0));
 
endmodule
 

