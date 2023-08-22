`timescale 1ns/100ps
import SystemVerilogCSP::*;

module noc_snn(
    interface load_start,
    interface ifmap_data,
    interface ifmap_addr,
    interface timestep,
    interface filter_data,
    interface filter_addr,
    interface load_done,
    interface start_r,
    interface ts_r,
    interface layer_r,
    interface done_r,
    interface out_spike_addr,
    interface out_spike_data
);

// parameters
    parameter WIDTH = 8;
    parameter WIDTH_O = 13;
    parameter DEPTH_F= 5;
    parameter DEPTH_I =25;
    parameter DEPTH_R =21;
    // parameter logic [2:0] TYPE [0:4] = '{3'b000, 3'b001, 3'b010, 3'b011, 3'b100};
    parameter logic [3:0] NODE_ADDR [0:9] = '{4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100};

    Channel #(.hsProtocol(P4PhaseBD), .WIDTH(44)) intf[35:0] (); 

    ifmap ifm (.ifmap_addr(ifmap_addr), .ifmap_data(ifmap_data), .timestep(timestep), .load_done(load_done), .ifmap_out(intf[0]));
    filter flm (.filter_addr(filter_addr), .filter_data(filter_data), .load_start(load_start), .load_done(load_done), .filter_out(intf[1]));
    router_t1 #(.LOCAL_ADDR(NODE_ADDR[0]))
        nd0(.in_left(intf[0]), .in_down(intf[2]), .out_right(intf[3]), .router_out1(intf[4]), .router_out2(intf[5]));
    router_t1 #(.LOCAL_ADDR(NODE_ADDR[1]))
        nd1(.in_left(intf[3]), .in_down(intf[8]), .out_right(intf[9]), .router_out1(intf[10]), .router_out2(intf[11]));
    router_t1 #(.LOCAL_ADDR(NODE_ADDR[2]))
        nd2(.in_left(intf[9]), .in_down(intf[15]), .out_right(intf[16]), .router_out1(intf[17]), .router_out2(intf[18]));
    router_t1 #(.LOCAL_ADDR(NODE_ADDR[3]))
        nd3(.in_left(intf[16]), .in_down(intf[22]), .out_right(intf[23]), .router_out1(intf[24]), .router_out2(intf[25]));
    router_t1 #(.LOCAL_ADDR(NODE_ADDR[4]))
        nd4(.in_left(intf[23]), .in_down(intf[29]), .out_right(intf[30]), .router_out1(intf[31]), .router_out2(intf[32]));
    router_t2 #(.LOCAL_ADDR(NODE_ADDR[5])) 
        nd5(.in_left(intf[1]), .out_up(intf[2]), .out_right(intf[7]));
    router_t2 #(.LOCAL_ADDR(NODE_ADDR[6])) 
        nd6(.in_left(intf[7]), .out_up(intf[8]), .out_right(intf[14]));
    router_t2 #(.LOCAL_ADDR(NODE_ADDR[7])) 
        nd7(.in_left(intf[14]), .out_up(intf[15]), .out_right(intf[21]));
    router_t2 #(.LOCAL_ADDR(NODE_ADDR[8])) 
        nd8(.in_left(intf[21]), .out_up(intf[22]), .out_right(intf[28]));
    router_t2 #(.LOCAL_ADDR(NODE_ADDR[9])) 
        nd9(.in_left(intf[28]), .out_up(intf[29]), .out_right(intf[35]));
    pe pe0(.filter_in(intf[4]), .ifmap_in(intf[5]), .psum_out(intf[6]));
    pe pe1(.filter_in(intf[10]), .ifmap_in(intf[11]), .psum_out(intf[12]));
    pe pe2(.filter_in(intf[17]), .ifmap_in(intf[18]), .psum_out(intf[19]));
    pe pe3(.filter_in(intf[24]), .ifmap_in(intf[25]), .psum_out(intf[26]));
    pe pe4(.filter_in(intf[31]), .ifmap_in(intf[32]), .psum_out(intf[33]));
    sum sm0(.in1(intf[6]), .in2(intf[12]), .out(intf[13]));
    sum sm1(.in1(intf[13]), .in2(intf[19]), .out(intf[20]));
    sum sm2(.in1(intf[20]), .in2(intf[26]), .out(intf[27]));
    sum sm3(.in1(intf[27]), .in2(intf[33]), .out(intf[34]));
    ofmap om(.ofmap_data(intf[34]), .out_spike_addr(out_spike_addr), .out_spike_data(out_spike_data), .start_r(start_r), .ts_r(ts_r), .layer_r(layer_r), .done_r(done_r));

endmodule