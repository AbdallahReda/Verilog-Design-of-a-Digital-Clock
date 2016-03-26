//
//  clock_divider.v
//	VE270 Lab #6 Design of a Digital Clock
//
//  Created by Hua Xing on 6/26/15.
//  Copyright (c) 2015 Hua Xing. All rights reserved.
//

// code currently optimized for simulation
// for implementation with system clock at 50 million Hz, modify two lines of code
// 1. "clock_divider #(.input_hz(6), .output_hz(1)) clock_divider_500_hz(.reset(reset), .clock_in(clock), .clock_out(w1));"
// to "clock_divider #(.input_hz(50_000_000), .output_hz(500)) clock_divider_500_hz(.reset(reset), .clock_in(clock), .clock_out(w1));"
// 2. "clock_divider #(.input_hz(8), .output_hz(1)) clock_divider_1_hz(.reset(reset), .clock_in(w1), .clock_out(w2));"
// to "clock_divider #(.input_hz(500), .output_hz(1)) clock_divider_1_hz(.reset(reset), .clock_in(w1), .clock_out(w2));"

module digital_clock (clock, reset, AN3, AN2, AN1, AN0, CA, CB, CC, CD, CE, CF, CG);
	input clock, reset;
	output AN3, AN2, AN1, AN0, CA, CB, CC, CD, CE, CF, CG;
	wire w1, w2;
	wire [3:0] w3;
	wire [3:0] w4;
	wire [6:0] w5;
	wire [6:0] w6;
	wire [6:0] w7;
	wire [6:0] w8;
	wire [3:0] w9;
	reg [6:0] reg1;

	clock_divider #(.input_hz(6), .output_hz(1)) clock_divider_500_hz(.reset(reset), .clock_in(clock), .clock_out(w1));
	clock_divider #(.input_hz(8), .output_hz(1)) clock_divider_1_hz(.reset(reset), .clock_in(w1), .clock_out(w2));
	timer_00_59 timer(.reset(reset), .clock(w2), .out_left_BCD(w3), .out_right_BCD(w4));
	ssd_driver ssd_driver_tens(.in_BCD(w3), .out_SSD(w6));
	ssd_driver ssd_driver_ones(.in_BCD(w4), .out_SSD(w7));
	ring_counter_4_bit ring_counter(.reset(reset), .clock(w1), .out(w9));

	// cathode input driver for two leftmost SSD
	always @(posedge w2) begin // activate with rising edge of 1 Hz clock
		reg1 <= 7'b1111111;
	end
	assign w5 = reg1;

	negative_tri_state_buffer_N_bit #(7) buffer_3 (.in_disable(w9[3]), .in(w5), .out(w8));
	negative_tri_state_buffer_N_bit #(7) buffer_2 (.in_disable(w9[2]), .in(w5), .out(w8));
	negative_tri_state_buffer_N_bit #(7) buffer_1 (.in_disable(w9[1]), .in(w6), .out(w8));
	negative_tri_state_buffer_N_bit #(7) buffer_0 (.in_disable(w9[0]), .in(w7), .out(w8));

	// now assign SSD ports
	assign AN3 = w9[3];	
	assign AN2 = w9[2];
	assign AN1 = w9[1];
   	assign AN0 = w9[0];
	assign CA = w8[6];
	assign CB = w8[5];
	assign CC = w8[4];
	assign CD = w8[3];
	assign CE = w8[2];
	assign CF = w8[1];
	assign CG = w8[0];
endmodule

module ring_counter_4_bit (reset, clock, out);
	input reset, clock;
	output [3:0] out;
	reg [3:0] out;

	always @(posedge clock or posedge reset) begin
		if (reset) begin
			out <= 4'b0111;
		end
		else begin
			out[3] <= out[0];
			out[2] <= out[3];
			out[1] <= out[2];
			out[0] <= out[1];	
		end
	end
endmodule

module clock_divider (reset, clock_in, clock_out);
	parameter input_hz = 6;
	parameter output_hz = 1;
	parameter in_out_ratio = input_hz / output_hz; // can process upmost 2^20 = 1048576 ratio

	input clock_in, reset;
	output clock_out;
	reg clock_out;
	reg [19:0] internal_count;

	always @(posedge clock_in or posedge reset) begin
		if (reset) begin
			internal_count <= 'b0;
			clock_out <= 1'b0;
		end
		else if (internal_count == (in_out_ratio - 1)) begin
			internal_count <= 20'b0;
			clock_out <= 1'b1; // time to shoot a rising edge
		end
		else if (internal_count == (in_out_ratio/2 - 1)) begin
			clock_out <= 1'b0; 	// holding time passed
			internal_count <= internal_count + 1;
		end
		else begin
			internal_count <= internal_count + 1;
		end
	end
endmodule

module timer_00_59 (reset, clock, out_left_BCD, out_right_BCD);
	input reset, clock;
	output [3:0] out_left_BCD; // Binary-Coded Decimal
	output [3:0] out_right_BCD;
	reg [3:0] out_left_BCD;
	reg [3:0] out_right_BCD;

	always @(posedge clock or posedge reset) begin
		if (reset) begin
			out_left_BCD <= 4'd0;
			out_right_BCD <= 4'd0;
		end
		else begin
			if (out_right_BCD == 4'd9) begin
				out_right_BCD <= 4'd0;
				if (out_left_BCD == 4'd5) begin
					out_left_BCD <= 4'd0;
				end
				else begin
					out_left_BCD <= out_left_BCD + 1;
				end
			end
			else begin
				out_right_BCD <= out_right_BCD + 1;
			end
		end
	end
endmodule

module ssd_driver (in_BCD, out_SSD);
	input [3:0] in_BCD; // input in Binary-Coded Decimal format
	output [6:0] out_SSD; // output to Seven-Segment Display
	reg [6:0] out_SSD;

	always @(in_BCD) begin
		case (in_BCD)
			4'd0: out_SSD <= 7'b0000001;
			4'd1: out_SSD <= 7'b1001111;
			4'd2: out_SSD <= 7'b0010010;
			4'd3: out_SSD <= 7'b0000110;
			4'd4: out_SSD <= 7'b1001100;
			4'd5: out_SSD <= 7'b0100100;
			4'd6: out_SSD <= 7'b0100000;
			4'd7: out_SSD <= 7'b0001111;
			4'd8: out_SSD <= 7'b0000000;
			4'd9: out_SSD <= 7'b0000100;
			default out_SSD <= 7'b0110000; // "E" for error
		endcase
	end
endmodule 

module negative_tri_state_buffer_N_bit (in_disable, in, out);
	parameter N = 7;
	input in_disable;
	input [N-1:0] in;
	output [N-1:0] out;
	reg [N-1:0] out;

	always @(in_disable or in) begin
		if (in_disable == 1'b0) out <= in;
		else out <= 'bz;
	end
endmodule

`timescale 1ns/1ps
module test_bench;
	reg clock, reset;
	wire AN3, AN2, AN1, AN0;
	wire CA, CB, CC, CD, CE, CF, CG;	

	initial begin
  		$monitor ("With clock at %b, reset at %b, anode gets %b%b%b%b, cathode gets %b%b%b%b%b%b%b", clock, reset, AN3, AN2, AN1, AN0, CA, CB, CC, CD, CE, CF, CG);
  		clock = 1'b0;
  		reset = 1'b0;

  		#5 reset = 1'b1;
  		#5 reset = 1'b0;
 
  		#50000 reset = 1'b1;
  		#20 reset = 1'b0; 

  		#1000 $finish;
	end

	always begin // clock cycle is #10
 		#5 clock = ~clock;
	end

 	digital_clock UUT (.clock(clock), 
 						.reset(reset), 
 						.AN3(AN3), .AN2(AN2), .AN1(AN1), .AN0(AN0), 
 						.CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG));
endmodule