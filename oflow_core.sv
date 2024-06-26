/*------------------------------------------------------------------------------
* File          : oflow_core.sv
* Project       : RTL
* Author        : epchof
* Creation date : Jan 13, 2024
* Description   :	
*------------------------------------------------------------------------------*/

	
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"


//number of proccessing engin is 22 thus we need 5 bit 
`define NUMBER_OF_PE_INSTANSIATION 22
// `define BIT_NUMBER_OF_PE 22

module oflow_core #() (
	//inputs
	input logic clk,
	input logic reset_N,
		
	input logic start,
	
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
  
	 input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_array_per_frame [`MAX_BBOXES_PER_FRAME-1:0],			//size 
	 
	 input logic [`REGISTER_DATA_LEN-1:0] w_iou,
	 input logic [`REGISTER_DATA_LEN-1:0] w_w,
	 input logic [`REGISTER_DATA_LEN-1:0] w_h, 
	 input logic [`REGISTER_DATA_LEN-1:0] w_color1, 
	 input logic [`REGISTER_DATA_LEN-1:0] w_color2,
	 input logic [`REGISTER_DATA_LEN:0] w_dhistory,
	 
	 input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frame,
	 
	 
	 input logic [31:0] apb_prdata,
	 
	 // outputs	
	 
	 output logic [4:0] th_conflict_counter,
	 // output logic th_conflict_counter_wr,
	 output logic done_for_dma, 
	 
	 output logic done_frame,
	 output logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME-1:0] );

// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  

// logics for MEM_buffer

logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num;//the serial number of the current frame 0-255
logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames; // fallback number
logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame; // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL
		
logic [`DATA_WIDTH-1:0] data_in_0;
logic [`DATA_WIDTH-1:0] data_in_1;
logic [`OFFSET_WIDTH-1:0] offset_0;
logic [`OFFSET_WIDTH-1:0] offset_1;
		
logic we;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 nable

//outputs
logic [`DATA_WIDTH-1:0] data_out_0;
logic [`DATA_WIDTH-1:0] data_out_1;


// logics for PE




// logics for Conflict_Resolve




// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  

/*
genvar i;
generate for  ( i=0;i<`K; i++) 
begin 
   oflow_PE oflow_PE_inst( 
		   .clk(clk),
		   .reset_N(reset_N)	,
		   .data_in(data_in[i]),
		   .wr(wr[i]),
		   .addr(addr[i]),
		   .EN(EN),
		   
		   
		   .data_out(data_out[i])
	   );
end
endgenerate


*/

oflow_MEM_buffer oflow_MEM_buffer(  
	.clk(clk),
	.reset_N (reset_N)	,
	
	.frame_num (frame_num),
	.num_of_history_frames (num_of_history_frames) ,
	.num_of_bbox_in_frame (num_of_bbox_in_frame),
	.data_in_0 (data_in_0),
	.data_in_1 (data_in_1),
	.offset_0 (offset_0),
	.offset_1 (offset_1), 
	.we (we),	
	.data_out_0 (data_out_0),
	.data_out_1 (data_out_1)
	
	);
	 
	  



endmodule	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*
		   input logic clk,
		   input logic reset_N	,
		   input logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_in,//[5-1:0]->22 PEs
		   input logic [`BIT_NUMBER_OF_PE-1:0] wr,
		   input logic [`BIT_NUMBER_OF_PE-1:0][7:0] addr,
		   input logic  EN,


		   output logic [`BIT_NUMBER_OF_PE-1:0][111:0] data_out
		   );
		   
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  



// -----------------------------------------------------------       
//				Instanciation
// -----------------------------------------------------------
 
//------------------PEs------------	 
genvar i;
generate for  ( i=0;i<`K; i++) 
begin 
   oflow_PE oflow_PE_inst( 
		   .clk(clk),
		   .reset_N(reset_N)	,
		   .data_in(data_in[i]),
		   .wr(wr[i]),
		   .addr(addr[i]),
		   .EN(EN),
		   
		   
		   .data_out(data_out[i])
	   );
end
endgenerate
/*
//------------------conflict resolve------------
oflow_conflict_resolve #() (
   input logic clk,
   input logic reset_N	,
	   
	input logic[43:0] num_of_row_to_read_from_mem,
	input logic[43:0] is_conflicr_resolve_state_EN,
	input logic[10:0] num_of_fall_back,
	input logic[10:0] max_bbox,
	input logic[10:0] 
	
	output logic[20:0] th_conf_counter
	output logic[20:0] id  ); */
//------------------mem manager------------	 
/*oflow_mem_manager*/
	
	
	

endmodule