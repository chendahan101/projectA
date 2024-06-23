
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
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
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
	
	mem mem(.clk(clk),
			.reset_N(reset_N),
			.address_0(addr_0),
			.address_1(addr_1),
			.data_in_0(data_in_0),
			.data_in_1(data_in_1),
			.data_out_0(data_out_0),
			.data_out_1(data_out_1),
			.cs_0(1'b1),
			.cs_1(1'b1),
			.we_0(we),
			.we_1(we),
			.oe_0(oe),
			.oe_1(oe)
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
					pointers[1] = 125;
				end
				3: begin 
					pointers[0] = 0;
					pointers[1] = 84;
					pointers[2] = 168;
				end
				4: begin 
					pointers[0] = 0;
					pointers[1] = 63;
					pointers[2] = 126;
					pointers[3] = 189;

				end			
				5: begin 
					pointers[0] = 0;
					pointers[1] = 50;
					pointers[2] = 100;
					pointers[3] = 150;
					pointers[4] = 200;
				end	
			endcase
		end
		else begin
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
		end
	end
	
	assign oe = (we) ?  1'b0 : 1'b1;
	


endmodule