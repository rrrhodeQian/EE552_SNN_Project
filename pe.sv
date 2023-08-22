`timescale 1ns/100ps

module pe (
    interface filter_in, 
    interface ifmap_in, 
    interface psum_out// all 40-bit
);
    parameter WIDTH = 8;
    parameter DEPTH_I = 25;
    // parameter ADDR_I = 5;
    parameter DEPTH_F = 5;
    // parameter ADDR_F = 3;
    parameter PACKET_D_WIDTH = 40;
    parameter DIN_WIDTH_I = 25;
    parameter WIDTH_O = 13;
    parameter ADDR_WIDTH = 5;
    parameter FL = 2;
    parameter BL = 2;

    logic [PACKET_D_WIDTH-1:0] filter_data_in;
    logic [PACKET_D_WIDTH-1:0] ifmap_data_in;
    logic [WIDTH-1:0] filter [DEPTH_F-1:0];
    logic ifmap [DEPTH_I-1:0];
    logic [PACKET_D_WIDTH-1:0] psum;
    int no_iterations = DEPTH_I - DEPTH_F;
    logic flag = 0;// indicate receive filter value done
    logic [ADDR_WIDTH-1:0] row_counter = 'b0;// counter to count which row of ifmap received
    logic [ADDR_WIDTH-1:0] col_counter = 'b0;

    always begin
        if (flag == 1'b0) begin
            fork
                filter_in.Receive(filter_data_in);
                ifmap_in.Receive(ifmap_data_in);
            join
            flag = 1'b1;//raise the flag to indicate received filter value
            // divide filter_data_in
            filter[0] = filter_data_in[7:0];
            filter[1] = filter_data_in[15:8];
            filter[2] = filter_data_in[23:16];
            filter[3] = filter_data_in[31:24];
            filter[4] = filter_data_in[39:32];
            // row_counter = 'b0;// tag which row to be computed
        end
        else begin
            ifmap_in.Receive(ifmap_data_in);
            // row_counter += 1'b1;// tag which row to be computed
        end
        #FL;

        for (int i = 0; i < DIN_WIDTH_I; i++) begin
            ifmap[i] = ifmap_data_in[i];
        end

        for (int x = 0; x <= no_iterations; x ++) begin
            psum = 13'b0;
            for (int y = 0; y < DEPTH_F; y++) begin
                psum += filter[y] & {8{ifmap[x+y]}};
                $display("psum: %d,filter: %d, ifmap %b",psum,filter[y],ifmap[x+y]);
            end
            col_counter = x;// convert x to logic type
            psum = {row_counter, col_counter, 17'b0, psum[WIDTH_O-1:0]};
            psum_out.Send(psum);
            #BL;
        end

        row_counter += 1'b1;
        
        if (row_counter == no_iterations + 1) begin// reinitialize row counter for next time step
            row_counter = 'b0;
        end
    end
endmodule