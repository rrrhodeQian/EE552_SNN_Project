`timescale 1ns/100ps
import SystemVerilogCSP::*;

module ofmap (
    interface ofmap_data,
    interface out_spike_addr,
    interface out_spike_data,
    interface start_r,
    interface ts_r,
    interface layer_r,
    interface done_r
);
    parameter PACKET_D_WIDTH = 40;
    parameter ADDR_WIDTH = 5;
    parameter WIDTH_O = 13;
    parameter DEPTH_R = 21;
    parameter FL = 12;
    parameter BL = 4;
    parameter threshold = 64;

    logic [PACKET_D_WIDTH-1:0] din;
    logic [WIDTH_O-1:0] residue_mem [0:DEPTH_R-1][0:DEPTH_R-1];
    // logic [WIDTH_O-1:0] residue = '0;
    logic spike_mem [DEPTH_R*DEPTH_R-1:0];
    logic [1:0] ts = 1;
    // logic st_r;

    always begin
        // start_r.Receive(st_r);
        start_r.Send(1);
        $display("start_r received at %t",$realtime);
        // for (int index = 1; index < 3; index++) begin
            ts_r.Send(1);
            layer_r.Send(1);
            for (int i = 0; i < DEPTH_R*DEPTH_R; i++) begin
                ofmap_data.Receive(din);
                residue_mem [din[39:35]] [din[34:30]] = din[WIDTH_O-1:0];
                $display("ts = 1 output %d received %d", i, din[WIDTH_O-1:0]);
                if (residue_mem [din[39:35]] [din[34:30]] > threshold) begin
                    residue_mem [din[39:35]] [din[34:30]] -= threshold;
                    spike_mem[i] = 1'b1;
                    out_spike_addr.Send(i);
                    out_spike_data.Send(spike_mem[i]);
                end
                else begin
                    // residue = din[WIDTH_O-1:0];
                    // residue_mem [din[39:35]] [din[34:30]] += residue;
                    spike_mem[i] = 1'b0;
                    out_spike_addr.Send(i);
                    out_spike_data.Send(spike_mem[i]);
                end
            end

            ts_r.Send(2);
            layer_r.Send(1);
            for (int i = 0; i < DEPTH_R*DEPTH_R; i++) begin
                ofmap_data.Receive(din);
                residue_mem [din[39:35]] [din[34:30]] += din[WIDTH_O-1:0];
                $display("ts = 2 output %d received %d", i, din[WIDTH_O-1:0]);

                if (residue_mem [din[39:35]] [din[34:30]] > threshold) begin
                    residue_mem [din[39:35]] [din[34:30]] -= threshold;
                    spike_mem[i] = 1'b1;
                    out_spike_addr.Send(i);
                    out_spike_data.Send(spike_mem[i]);
                end
                else begin
                    // residue = din[WIDTH_O-1:0];
                    // residue_mem [din[39:35]] [din[34:30]] += residue;
                    spike_mem[i] = 1'b0;
                    out_spike_addr.Send(i);
                    out_spike_data.Send(spike_mem[i]);
                end
            end
        // end
        done_r.Send(1);
    end
endmodule