// Title: vga.v
// Author: Tristen Gesler
// Tools: Quartus Prime Lite 18.0
// Description: Displays a MIF file to a monitor via VGA
//
// ----------------------------------------------------------------------------------
// |  LE/ALMS  |  # Multipliers  |  FMax (slow 85c)  |  Fmax Restricted (slow 85c)  |
// ----------------------------------------------------------------------------------
// |    202    |         ?       |     587.2 MHz     |          364.7 MHz           |
// ----------------------------------------------------------------------------------


module vga(
	input CLOCK_50,
	input [9:0] SW,
	output [7:0] VGA_B, VGA_G, VGA_R,
	output VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS
);

parameter Ha = 96, Hb = 144, Hc = 784, Hd = 800;
parameter Va = 2, Vb = 35, Vc = 515, Vd = 525;

wire clk;
wire red_switch, green_switch, blue_switch;
reg pixel_clk;
reg Hsync, Vsync;
wire [7:0] R, G, B;
wire nblanck, nsync;
reg Hactive, Vactive;
wire dena;
reg [18:0] address;
reg [7:0] intensity;
integer Hcount = 0;

assign clk = CLOCK_50;
assign red_switch = SW[0], green_switch = SW[1], blue_switch = SW[2];
assign VGA_CLK = pixel_clk;
assign VGA_HS = Hsync, VGA_VS = Vsync;
assign VGA_R = R, VGA_G = G, VGA_B = B;
assign VGA_BLANK_N = nblanck, VGA_SYNC_N = nsync;



assign nblanck = 1;
assign nsync = 0;

always @(posedge clk) begin
	pixel_clk = ~pixel_clk;
end

always @(posedge pixel_clk)
begin
	Hcount = Hcount + 1;
	if (Hcount == Ha)
		Hsync = 1;
	else if (Hcount == Hb)
		Hactive = 1;
	else if (Hcount == Hc)
		Hactive = 0;
	else if (Hcount == Hd) begin
		Hsync = 0;
		Hcount = 0;
	end
end

integer Vcount = 0;
always @(negedge Hsync)
begin
	Vcount = Vcount + 1;
	if(Vcount == Va)
		Vsync = 1;
	else if(Vcount == Vb)
		Vactive = 1;
	else if(Vcount == Vc)
		Vactive = 0;
	else if(Vcount == Vd) begin
		Vsync = 0;
		Vcount = 0;
	end
end

assign dena = Hactive & Vactive;

lpm_rom myrom( .q(intensity), .inclock(~pixel_clk), .address(address));
	defparam myrom.lpm_widthad = 19;
	defparam myrom.lpm_numwords = 307200;
	defparam myrom.lpm_outdata = "UNREGISTERED";
	defparam myrom.lpm_address_control = "REGISTERED";
	defparam myrom.lpm_file = "Headshot.mif";
	defparam myrom.lpm_width = 8; 

integer line_counter = 0;

always @(negedge Vsync, posedge Hsync)
begin
	if (Vsync == 0)
		line_counter = 0;
	else if (Hsync == 1) begin
		if (Vactive == 1)
			line_counter = line_counter + 1;
	end
	address = line_counter * 640 + Hcount - Hb;
end

assign R = intensity;
assign G = intensity;
assign B = intensity;

endmodule