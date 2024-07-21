/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"

`define DATA_TO_PE_WIDTH (`FEATURE_OF_PREV_LEN+`D_HISTORY_LEN ) //142+3=145


module oflow_interface_mem_pe #() (


	input logic clk,
	input logic reset_N ,
	// global inputs
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	//input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	
//for read from mem buffer

	//control signal
	//from buffer wrapper
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface,

	//data to read , come from buffer mem
	//data width will be 284
	input logic [`DATA_WIDTH-1:0] data_out_from_buffer_mem ,//output of mem buffer, but this is input to interface

	//data to pe
	output logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_0,// we will change the d_history_field
	output logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_1,// we will change the d_history_field



//for write to mem buffer

	//control signal
	//from core fsm write
	input logic [`REMAINDER_LEN-1:0] remainder,  
	input logic [`ROW_LEN-1:0] row_sel_from_core_fsm,//from core fsm
	input logic [`PE_LEN-1:0] pe_sel,
	
	output logic [`ROW_LEN-1:0] row_sel_to_pe,//to pe

	//data to write , come from pe
	//we will change FEATURE_OF_PREV_LEN from 145 to 142 (In mem_buffer we won't save d_history)
	input logic [`FEATURE_OF_PREV_LEN-1:0] data_out_pe [`PE_NUM],

	//data out to mem buffer
	//we will change FEATURE_OF_PREV_LEN from 290 to 284 (In mem_buffer we won't save d_history)
	output logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_0,
	output logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_1


);





// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

	logic [`FEATURE_OF_PREV_LEN-1:0] data_out [`DATA_OUT_NUM],
	



	  
	 
	 
 // -----------------------------------------------------------       
 //						 Async Logic
 // -----------------------------------------------------------	
 //for write
 
 always_comb begin
	
	data_out[0] = data_out_pe[pe_sel*4+0];
	data_out[1] = data_out_pe[pe_sel*4+1];
	data_out[2] = data_out_pe[pe_sel*4+2];
	data_out[3] = data_out_pe[pe_sel*4+3];
	
	 case (remainder)
		 0: begin
			 data_in_for_buffer_mem_0 = {data_out[0],data_out[1]};
			 data_in_for_buffer_mem_1 = {data_out[2],data_out[3]};
		 end
		 
		 1: begin
			 data_in_for_buffer_mem_0 = {data_out[0],`FEATURE_OF_PREV_LEN{1'b0}};
			 data_in_for_buffer_mem_1 = 0;
			
		 end
		 
		 2: begin 
			 data_in_for_buffer_mem_0 = {data_out[0],data_out[1]};
			 data_in_for_buffer_mem_1 = 0; 
		 end
		 
		 3: begin 
			 data_in_for_buffer_mem_0 = {data_out[0],data_out[1]};
			 data_in_for_buffer_mem_1 = {data_out[2],`FEATURE_OF_PREV_LEN{1'b0}}; 
		 end
		 
	 endcase
 end
	  
	  
assign row_sel_to_pe = row_sel_from_core_fsm;
	

//for read	
 
assign data_to_pe_0 = {data_out_from_buffer_mem[`DATA_WIDTH-1:`DATA_WIDTH-`FEATURE_OF_PREV_LEN+`ID_LEN],counter_of_history_frame_to_interface,data_out_from_buffer_mem[`DATA_WIDTH-`FEATURE_OF_PREV_LEN+`ID_LEN-1-:`ID_LEN]};
assign data_to_pe_1 = {data_out_from_buffer_mem[`DATA_WIDTH-`FEATURE_OF_PREV_LEN-1:`ID_LEN],counter_of_history_frame_to_interface,data_out_from_buffer_mem[`ID_LEN-1:0]} 
 
	
	 
endmodule
