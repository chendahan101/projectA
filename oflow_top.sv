/*------------------------------------------------------------------------------
 * File          : oflow_top.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 6, 2024
 * Description   :
 *----------------------------------------------------------------------*/

`include "/users/epchof/Project/design/work/include_files/oflow_core_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_MEM_buffer_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_reg_file_define.sv"

//`timescale 1ns/100ps
module oflow_top ( 
	  // inputs
	  input logic clk,
	  input logic reset_N,
	  
	  
	  // globals inputs and outputs (DMA)
	  input logic [`BBOX_VECTOR_SIZE-1:0] set_of_bboxes_from_dma [`PE_NUM],
	  input logic start, // from top
	  input logic new_set_from_dma, // dma ready with new feature extraction set
	  input logic [`NUM_OF_BBOX_IN_FRAME_WIDTH-1:0] num_of_bbox_in_frame, // TO POINT TO THE END OF THE FRAME MEM, SO WE WILL READ ONLY THE FULL CELL --- maybe to remove
	  input logic new_frame,
	  output logic ready_new_set, // fsm_core_top ready for new_set from DMA
	  output logic ready_new_frame, // fsm_core_top ready for new_frame from DMA
	  output logic conflict_counter_th, // fsm_core_top ready for new_frame from DMA
	  
	   
	  // APB Interface	
	  
	  // inputs
	  input logic [31:0] apb_pwdata,		
	  input logic apb_pwrite,
	  input logic apb_psel, 
	  input logic apb_penable,
	  input logic[`ADDR_LEN-1:0] apb_addr,
	  // outputs
	  output logic apb_pready,      
	  output logic[31:0] apb_prdata, 
	   
	   
	  output logic valid_id,
	  output logic [`ID_LEN-1:0] ids [`MAX_BBOXES_PER_FRAME] ); 
// -----------------------------------------------------------       
//                 Registers & Wires
// -----------------------------------------------------------  

 // reg_file
 logic [`WEIGHT_LEN-1:0] iou_weight;
 logic [`WEIGHT_LEN-1:0] w_weight;
 logic [`WEIGHT_LEN-1:0] h_weight; 
 logic [`WEIGHT_LEN-1:0] color1_weight; 
 logic [`WEIGHT_LEN-1:0] color2_weight;
 logic [`WEIGHT_LEN-1:0] dhistory_weight;
 logic [`SCORE_LEN-1:0] score_th_for_new_bbox;
 logic [`NUM_OF_HISTORY_FRAMES_WIDTH-1:0]  num_of_history_frames;
 logic [`MAX_THRESHOLD_FOR_CONFLICTS_LEN-1:0]  max_threshold_for_conflicts;



 

 
  
 

// -----------------------------------------------------------       
//                Instantiations
// -----------------------------------------------------------  


oflow_reg_file  oflow_reg_file( .* );


oflow_core  oflow_core( .* );


  


endmodule