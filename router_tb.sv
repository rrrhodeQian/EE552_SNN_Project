`timescale 1ns/100ps
import SystemVerilogCSP::*;

//router testbench
module router_tb(
    interface in_up,
    interface in_down,
    interface in_left,
    interface in_right,
    interface in_local_data, //40-bit
    interface out_up,
    interface out_down,
    interface out_left,
    interface out_right,
    interface router_out1, //40-bit
    interface router_out2 //40-bit
);

    parameter WIDTH = 8;
    parameter WIDTH_O = 13;
    parameter DEPTH_I = 25;
    parameter DEPTH_F = 5;
    parameter DEPTH_O = 21;
    parameter PACKET_D_WIDTH = 40;
    parameter PACK_WIDTH = 64;
    logic [PACK_WIDTH-1:0] data_pack;
    logic [PACKET_D_WIDTH-1:0] data;
    // logic [PACK_WIDTH-1:0] psum_pack1;
    // logic [PACK_WIDTH-1:0] psum_pack2;
    // logic [PACK_WIDTH-1:0] sum_out_pack;
    // logic [PACK_WIDTH-1:0] ifmap_pack;
    // logic [PACK_WIDTH-1:0] dout;
    // logic [PACKET_D_WIDTH-1:0] local_data_pack
    integer fpo, fpi_1, /*fpi_2,*/ status, don_e = 0, i = 0;

// watchdog timer
    initial begin
        #1000;
        $display("*** Stopped by watchdog timer ***");
        $stop;
    end

//load ifmap value
    initial begin
// loading memories
        #100;
        fpi_1 = $fopen("C:\\EE552_project\\data_pack.txt","r");
        // fpi_2 = $fopen("C:\\EE552_project\\data2.txt","r");
        fpo = $fopen("C:\\EE552_project\\router_tb.dump");
        if(!fpi_1)
        begin
            $display("A file cannot be opened!");
            $stop;
        end
    // for (int j = 0; j < 6; j ++) begin
        if(!$feof(fpi_1)) begin
	        status = $fscanf(fpi_1,"%b\n", data_pack);
	        $display("fp1 data read:%b", data_pack);
            in_up.Send(data_pack);
	        // to_in1.Send(data1);
	    end

        router_out1.Receive(data);
        #100;
        $stop;
    end
endmodule

module testbench;
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(64)) intf[7:0] ();
    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(40)) intf_s[2:0] ();

    parameter LOCAL_ADDR = 4'b1000;
    parameter DEST_ADDR = 4'b0001;
    parameter TYPE = 3'b000;

    router #(.LOCAL_ADDR(LOCAL_ADDR)) rt(.in_up(intf[0]), .in_down(intf[1]), .in_left(intf[2]), .in_right(intf[3]), .in_local_data(intf_s[0]), .out_up(intf[4]), .out_down(intf[5]), .out_left(intf[6]), .out_right(intf[7]), .router_out1(intf_s[1]), .router_out2(intf_s[2]));
    router_tb rt_tb(.in_up(intf[0]), .in_down(intf[1]), .in_left(intf[2]), .in_right(intf[3]), .in_local_data(intf_s[0]), .out_up(intf[4]), .out_down(intf[5]), .out_left(intf[6]), .out_right(intf[7]), .router_out1(intf_s[1]), .router_out2(intf_s[2]));

endmodule