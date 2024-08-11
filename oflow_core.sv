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

`define MAX_ROWS_IN_SCORE_BOARD 11 //COMES FROM: CEIL(TOTAL BBOX NUMBERS/PE NUM)=CEIL(256/24)=11

module oflow_core #() (
	//inputs
	input logic clk,
	input logic reset_N,
	

	// globals inputs and outputs (DMA)
	input logic [`BBOX_VECTOR_SIZE-1:0] set_of_bboxes_from_dma [`PE_NUM],
	input logic new_set_from_dma, // dma ready with new feature extraction set
	output logic ready_new_set, // fsm_core_top ready for new_set from DMA
	output logic ready_new_frame, // fsm_core_top ready for new_frame from DMA
	output logic conflict_counter_th, // fsm_core_top ready for new_frame from DMA
	
	// reg_file
	input logic [`WEIGHT_LEN-1:0] iou_weight,
	input logic [`WEIGHT_LEN-1:0] w_weight,
	input logic [`WEIGHT_LEN-1:0] h_weight,
	input logic [`WEIGHT_LEN-1:0] color1_weight,
	input logic [`WEIGHT_LEN-1:0] color2_weight,
	input logic [`WEIGHT_LEN-1:0] dhistory_weight
	
	input logic start, // from top
	input logic new_frame,
	
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255
	input logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0] num_of_history_frames, // fallback number
	input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	 
	 //input logic [`BBOX_VECTOR_SIZE-1:0] bboxes_array_per_frame [`MAX_BBOXES_PER_FRAME-1:0],			//size 
	 
	 
	 
	 
	 input logic [31:0] apb_prdata,
	 
	 // outputs	
	 
	
	 
	
	 output logic valid_id,
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
logic control_for_read_new_line_i [`PE_NUM];
logic [`DATA_WIDTH -1:0 ]data_out_pe [`PE_NUM];
logic [`ID_LEN-1:0] id_out[`MAX_ROWS_IN_SCORE_BOARD][`PE_NUM];
	
// logics for outputs of interface
logic done_read_to_pe;	
logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_0; // we will change the d_history_field
logic [`DATA_TO_PE_WIDTH -1:0] data_to_pe_1; // we will change the d_history_field
logic [`ROW_LEN-1:0] row_sel_to_pe;
logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_0;
logic [`DATA_WIDTH -1:0] data_in_for_buffer_mem_1;



// logics for outputs of core_fsm
logic rnw_st;

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
//                Assign
// -----------------------------------------------------------  
genvar r,j;

generate 
	for  ( r=0; r < `MAX_ROWS_IN_SCORE_BOARD; r+=1) begin :row
		for  ( j=0; j < `PE_NUM; j+=1) begin : pe
			assign ids[(r*(`PE_NUM))+j] = id_out[r][j];
		end
	end
endgenerate


// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  


genvar i;
generate for  ( i=0; i < `PE_NUM; i++) 
begin 
   oflow_pe oflow_pe( 
			.clk (clk),
			.reset_N (reset_N),
			
	  		 .num_of_pe(i[`PE_LEN-1:0]),
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
			.frame_num(frame_num),
			.start_fe (start_fe_i[i]),
			.start_registration(start_registration_i[i]),
			.done_pe (done_pe),
			.done_fe (done_fe_i[i]),
			.done_registration (done_registration_i[i]), 
	   .control_for_read_new_line (control_for_read_new_line_i[i]), // we want to start read new line after 2 cycles before the end; control_for_read_new_line_0 && ( control_for_read_new_line_1  || (~ |ID1)) 
			

			// interface between buffer&pe
			 .data_to_pe_0 (data_to_pe_0),// we will change the d_history_field
			 .data_to_pe_1 (data_to_pe_1),// we will change the d_history_field
			 .row_sel_to_pe (row_sel_to_pe),
			 .data_out_pe (data_out_pe[i]),
			 .done_read_to_pe (done_read_to_pe),
			//IDs
	   		 .id_out( id_out[`MAX_ROWS_IN_SCORE_BOARD][i])
	   	
			
	   );
end
endgenerate



oflow_mem_buffer_wrapper oflow_mem_buffer_wrapper(  
 .clk (clk),
 .reset_N (reset_N),
// control signal from core fsm
 .rnw_st(rnw_st),
 .ready_from_core(ready_from_core),	
 .read_new_line (read_new_line),
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

	.done_read (done_read),
	.done_read_to_pe (done_read_to_pe),

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
	
	
oflow_core_fsm_read oflow_core_fsm_read(
		.clk (clk),
		.reset_N (reset_N),
		
		 .num_of_sets (num_of_sets), 
		 .counter_of_remain_bboxes (counter_of_remain_bboxes), 
		
        
	    .done_read (done_read), 
	    .done_registration (done_registration), 
	    .start_read_mem_for_first_set (!counter_set_registration), 
	    .control_for_read_new_line (control_for_read_new_line_i),
	    
	    
	     .start_read (start_read), 
	     .read_new_line (read_new_line), 
	    
	     .counter_set_registration (counter_set_registration)
	
	);

oflow_core_fsm_write oflow_core_fsm_write(	
	
	
	.clk (clk),
	.reset_N (reset_N),
	// global inputs
	.num_of_bbox_in_frame (num_of_bbox_in_frame), // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	
	//from genreal fsm in core (after conflict_resolve done)
	.start_write (start_write),
	//from buffer 
	//input logic done_write_buffer,//only after core fsm ready to fetch us the next 2 line of data ; we are going to add a wait state to cure this. the wait state has to be sure the buffer is done to writes 2 rows and now we can change the PE's

	
	 .ready_from_core (ready_from_core), // send from fsm core to fsm buffer
	 .remainder (remainder), //if the fsm is in the remainder states
	 .row_sel (row_sel),
	 .pe_sel (pe_sel)
	
	);
	
	
oflow_core_fsm_fe oflow_core_fsm_fe(	
	.clk (clk),
	.reset_N (reset_N),
	
	//fsm_core_top
	.num_of_sets (num_of_sets), 
	.start_pe (start_pe),
	.counter_of_remain_bboxes (counter_of_remain_bboxes), // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	.new_set (new_set), // will help to know if new_set in the frame is waiting
	//output logic [`SET_LEN] counter_set_fe - need to check if need this because we draw it in module but we forgot
	.counter_set_fe (counter_set_fe) // for counter_of_remain_bboxes in core_fsm_top
	
	//oflow_core_fsm_registration
	.done_registration (done_registration),
	.done_fe (done_fe), // done_fe of all fe's in use
	
	
	// pe's
	.done_fe_i (done_fe_i),
	.start_fe_i (start_fe_i)
	
	);
	
oflow_core_fsm_registration oflow_core_fsm_registration(
	.clk (clk),
	.reset_N (reset_N),
	
	//fsm_core_top
	.num_of_sets (num_of_sets), 
	.counter_of_remain_bboxes (counter_of_remain_bboxes), // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	.done_pe (done_pe),
	
	
	//oflow_core_fsm_fe
	.done_fe (done_fe),
	.done_registration (done_registration), // done_registration of all registration's in use
	
	// pe's
	.done_registration_i (done_registration_i),
	.start_registration_i (start_registration_i),
	
	// oflow_core_fsm_read
	.counter_set_registration (counter_set_registration)	

	);
	
	
oflow_core_fsm_top oflow_core_fsm_top(
	 .clk (clk),
	 .reset_N (reset_N),
	
	// globals inputs and outputs
	.start (start), // from top
	.new_set_from_dma (new_set_from_dma), // dma ready with new feature extraction set
	.new_frame (new_frame),
	.ready_new_set (ready_new_set), // fsm_core_top ready for new_set from DMA
	.ready_new_frame (ready_new_frame), // fsm_core_top ready for new_frame from DMA
	
	
	// oflow_reg_file
	.num_of_history_frames (num_of_history_frames),
	.num_of_bbox_in_frame (num_of_bbox_in_frame), // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	//input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] frame_num,//the serial number of the current frame 0-255; We converted this to counter
	// input logic [`TOTAL_FRAME_NUM_WIDTH-1:0] num_of_total_frames,//the serial number of the current frame 0-255 ; we add ready_new_frame, change the FSM

	//oflow_core_fsm_fe
	.counter_set_fe (counter_set_fe), // for counter_of_remain_bboxes in core_fsm_top
	.start_pe (start_pe),
	.new_set (new_set), // will help to know if new_set in the frame is waiting
	
	//oflow_core_fsm_registration
	.done_pe (done_pe),
	
	.counter_of_remain_bboxes (counter_of_remain_bboxes), // will help us to choose how many pe to activate because sometimes current #bboxes_in_set < 24
	.num_of_sets (num_of_sets), 
	
	
	// oflow_MEM_buffer_wrapper
	.rnw_st(rnw_st),
	.done_write (done_write),
	.start_write_mem (start_write_mem),
	.frame_num (frame_num), // counter for frame_num
	
	//oflow_conflict_resolve
	.done_cr (done_cr), // cr: conflict resolve
	.conflict_counter_th(conflict_counter_th),
	.start_cr (start_cr),
	
	
	// write_score
	.start_write_score (start_write_score),
	//IDs
	.valid_id(valid_id)
	
	);
endmodule
