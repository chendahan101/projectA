
/*------------------------------------------------------------------------------
 * File          : oflow_MEM_buffer.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Feb 9, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"


module oflow_MEM_buffer #() (
	input logic clk,
	input logic reset_N,
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	
	input logic [`DATA_WIDTH-1:0] data_in_0,
	input logic [`DATA_WIDTH-1:0] data_in_1,
	
	input logic [`OFFSET_WIDTH-1:0] offset_0,
	input logic [`OFFSET_WIDTH-1:0] offset_1,
	
	input logic we,

	
	//input logic fe_enable,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       nable
	
	//outputs
	output logic [`DATA_WIDTH-1:0] data_out_0,
	output logic [`DATA_WIDTH-1:0] data_out_1) ;
	


//-----------------------------------------
//				Wire
//-----------------------------------------								
	logic [`ADDR_WIDTH-1:0] addr_0;
	logic [`ADDR_WIDTH-1:0] addr_1;
	logic [`ADDR_WIDTH-1:0] pointers [5];

	logic oe;


	
// -----------------------------------------------------------       
//				Instantiation
// ----------------------------------------------------------- 
	
	all_mem  #(.DATA_WIDTH_MEM (`DATA_WIDTH)) all_mem(.clk(clk),
			.reset_N(reset_N),
			.address_0(addr_0),
			.address_1(addr_1),
			.data_in_0(data_in_0),
			.data_in_1(data_in_1),
			.data_out_0(data_out_0),
			.data_out_1(data_out_1),
			.csb_0(1'b0),
			.csb_1(1'b0),
			.web_0(~we),//web =0 write, web=1 read. cause active low
			.web_1(~we),
			.oeb_0(1'b0),
			.oeb_1(1'b0)
	);
	
	
	
	always_comb begin
		if(!reset_N)
			pointers = '{0,0,0,0,0};
			
		if(frame_num==0) begin
			case(num_of_history_frames) 
				
				1: begin 
						pointers[0] = 0;
					end
				2: begin 
					pointers[0] = 0;
					pointers[1] = 64;
				end
				3: begin 
					pointers[0] = 0;
					pointers[1] = 42;
					pointers[2] = 84;
				end
				4: begin 
					pointers[0] = 0;
					pointers[1] = 32;
					pointers[2] = 64;
					pointers[3] = 96;

				end			
				5: begin 
					pointers[0] = 0;
					pointers[1] = 25;
					pointers[2] = 50;
					pointers[3] = 75;
					pointers[4] = 100;
				end	
			endcase
		end
		//else begin
			case(frame_num%num_of_history_frames) 
				0: begin 
					addr_0 = pointers[0] + offset_0;
					addr_1 = pointers[0] + offset_1;
					end
				1: begin 
					addr_0 = pointers[1] + offset_0;
					addr_1 = pointers[1] + offset_1;
					end
				2: begin 
					addr_0 = pointers[2] + offset_0;
					addr_1 = pointers[2] + offset_1;
					end
				3: begin 
					addr_0 = pointers[3] + offset_0;
					addr_1 = pointers[3] + offset_1;

					end			
				4: begin 
					addr_0 = pointers[4] + offset_0;
					addr_1 = pointers[4] + offset_1;
					end	
			endcase
		//end
	end
	
	assign oe = (we) ; // oe is active low 
	


endmodule
