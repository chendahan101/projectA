/*------------------------------------------------------------------------------
* File          : oflow_core.sv
* Project       : RTL
* Author        : epchof
* Creation date : Jan 13, 2024
* Description   :	
*------------------------------------------------------------------------------*/

	
`include "/users/epchof/Project/design/work/include_files/oflow_similarity_metric_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"



module oflow_core #() (
	//inputs
	input logic clk,
	input logic reset_N,
	

	// globals inputs and outputs (DMA)
	input logic [`BBOX_VECTOR_SIZE-1:0] set_of_bboxes_from_dma [`PE_NUM],
	input logic new_set_from_dma, // dma ready with new feature extraction set
	output logic ready_new_set, // fsm_core_top ready for new_set from DMA
	
	// reg_file
	input logic [`WEIGHT_LEN-1:0] iou_weight,
	input logic [`WEIGHT_LEN-1:0] w_weight,
	input logic [`WEIGHT_LEN-1:0] h_weight,
	input logic [`WEIGHT_LEN-1:0] color1_weight,
	input logic [`WEIGHT_LEN-1:0] color2_weight,
	input logic [`WEIGHT_LEN-1:0] dhistory_weight
	
	input logic start, // from top
	input logic new_frame,
	
	input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	 
	 //input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_array_per_frame [`MAX_BBOXES_PER_FRAME-1:0],			//size 
	 
	 
	 
	 
	 input logic [31:0] apb_prdata,
	 
	 // outputs	
	 
	 output logic [4:0] th_conflict_counter,
	 // output logic th_conflict_counter_wr,
	 output logic done_for_dma, 
	 
	 output logic done_frame,
	 output logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME] );



// -----------------------------------------------------------       
//              Logics
// -----------------------------------------------------------  




// logics for outputs of buffer_wrapper
logic done_read;
logic done_write;
logic [`DATA_WIDTH-1:0] data_out_0;
logic [`DATA_WIDTH-1:0] data_out_1;
logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] counter_of_history_frame_to_interface                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

// logics for outputs of PE
logic done_fe_i [`PE_NUM];
logic done_registration_i [`PE_NUM]; 
logic done_similarity_metric_i [`PE_NUM];
logic data_out_pe [`PE_NUM];
	
// logics for outputs of interface
logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_0; // we will change the d_history_field
logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_1; // we will change the d_history_field
logic [`ROW_LEN-1:0] row_sel_to_pe;
logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_0;
logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_1;


// logics for outputs of core_fsm

// core_fsm_top
logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num; //the serial number of the current frame 0-255
logic start_pe;
logic new_set;
logic [`REMAIN_BBOX_LEN-1:0] counter_of_remain_bboxes; // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
logic [`SET_LEN-1:0] num_of_sets; 
logic start_cr; //cr: conflict_resolve
logic start_write_mem;
logic start_write_score;
// core_fsm_fe
logic [`SET_LEN-1:0] counter_set_fe; // for counter_of_remain_bboxes in core_fsm_top	
logic done_fe; // done_fe of all fe's in use
logic start_fe_i [`PE_NUM];
// core_fsm_registration
logic done_pe;
logic done_registration; // done_registration of all registration's in use
logic start_registration_i [`PE_NUM];
logic [`SET_LEN-1:0] counter_set_registration;
// core_fsm_write
logic ready_from_core; // send from fsm core to fsm buffer
logic [`REMAINDER_LEN-1:0] remainder; //if the fsm is in the remainder states
logic [`ROW_LEN-1:0] row_sel;
logic [`PE_LEN-1:0] pe_sel;
// core_fsm_read
logic start_read;
logic read_new_line;

 // the similarity_metric will update this to AND of similarity_metric_0 & similarity_metric_1 in the registration

			

// logics for Conflict_Resolve




// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  


genvar i;
generate for  ( i=0; i < `PE_NUM; i++) 
begin 
   oflow_pe oflow_pe( 
			.clk (clk),
			.reset_N (reset_N)	,
			
			
			// reg_file
			.iou_weight (iou_weight),
			.w_weight (w_weight)  ,
			.h_weight (h_weight),
			.color1_weight (color1_weight),
			.color2_weight (color2_weight),
			.dhistory_weight (dhistory_weight),
			

			// dma
			.bboxes_from_dma (set_of_bboxes_from_dma[i]),
			
			// core_fsm
			.start_fe (start_fe_i[i]),
			.start_registration(start_registration_i[i]),
			.done_pe (done_pe),
			.done_fe (done_fe_i[i]),
			.done_registration (done_registration_i[i]), 
			.done_similarity_metric_i (done_similarity_metric_i[i]), // the similarity_metric will update this to AND of similarity_metric_0 & similarity_metric_1 in the registration
			

			// interface between buffer&pe
			 .data_to_pe_0 (data_to_pe_0),// we will change the d_history_field
			 .data_to_pe_1 (data_to_pe_1),// we will change the d_history_field
			 .row_sel_to_pe (row_sel_to_pe),
			 .data_out_pe (data_out_pe[i])
			
	   );
end
endgenerate



oflow_mem_buffer_wrapper oflow_mem_buffer_wrapper(  
 .clk (clk),
 .reset_N (reset_N),
// control signal from core fsm
 .start_read (start_read),
 .start_write (start_write_mem),
// data in from pe
 .data_in_0 (data_in_for_buffer_mem_0),
 .data_in_1 (data_in_for_buffer_mem_1),
//global variable
 .frame_num (frame_num),//the serial number of the current frame 0-255
 .num_of_history_frames (num_of_history_frames), // fallback number
 .num_of_bbox_in_frame (num_of_bbox_in_frame), // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove

//control signal for core fsm
 .done_read (done_read),
 .done_write (done_write),
//data out for pe
.data_out_0 (data_out_0),
.data_out_1 (data_out_1),

//data out for interface
 .counter_of_history_frame_to_interface(counter_of_history_frame_to_interface)
	
	);
	 
oflow_interface_mem_pe oflow_interface_mem_pe(

	 .clk (clk),
	 .reset_N (reset_N),
	// global inputs
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255
	//input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	
//for read from mem buffer

	//control signal
	//from buffer wrapper
	 .counter_of_history_frame_to_interface (counter_of_history_frame_to_interface),

	//data to read , come from buffer mem
	//data width will be 284
	 .data_out_from_buffer_mem (data_out_0) ,//output of mem buffer, but this is input to interface

	//data to pe
	 .data_to_pe_0 (data_to_pe_0),// we will change the d_history_field
	 .data_to_pe_1 (data_to_pe_1),// we will change the d_history_field



//for write to mem buffer

	//control signal
	//from core fsm write
	 .remainder (remainder),  
	 .row_sel_from_core_fsm (row_sel),//from core fsm
	 .pe_sel (pe_sel),
	
	 .row_sel_to_pe (row_sel_to_pe),//to pe

	//data to write , come from pe
	//we will change FEATURE_OF_PREV_LEN from 145 to 142 (In mem_buffer we won't save d_history)
	 .data_out_pe (data_out_pe),

	//data out to mem buffer
	//we will change FEATURE_OF_PREV_LEN from 290 to 284 (In mem_buffer we won't save d_history)
	 .data_in_for_buffer_mem_0 (data_in_for_buffer_mem_0),
	 .data_in_for_buffer_mem_1 (data_in_for_buffer_mem_1)	  

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