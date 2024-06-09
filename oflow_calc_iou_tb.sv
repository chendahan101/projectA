/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 19, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_calc_iou_define.sv"


module oflow_calc_iou_tb #() ();

   
// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

		   
	 logic clk;
	 logic reset_N;
	 logic start;
	 logic valid_iou;

	 logic[`BBOX_POSITION_FRAME-1:0] bbox_position_frame_k;   // {X_TL, Y_TL, X_BR, Y_BR}
	 logic[`BBOX_POSITION_FRAME-1:0] bbox_position_frame_history; // {X_TL, Y_TL, X_BR, Y_BR}
	 logic[`WIDTH_LEN-1:0] bbox_w_frame_k;
	 logic[`HEIGHT_LEN-1:0] bbox_h_frame_k;
	 logic[`WIDTH_LEN-1:0] bbox_w_frame_history;
	 logic[`HEIGHT_LEN-1:0] bbox_h_frame_history;
	 logic[`IOU_LEN-1:0] iou;
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------



oflow_calc_iou oflow_calc_iou  (.clk(clk),
	.reset_N(reset_N),
	.start(start),

	 .bbox_position_frame_k(bbox_position_frame_k)	,   // {X_TL, Y_TL, X_BR, Y_BR}
	 .bbox_position_frame_history(bbox_position_frame_history), // {X_TL, Y_TL, X_BR, Y_BR}
	 .bbox_w_frame_k(bbox_w_frame_k),
	 .bbox_h_frame_k(bbox_h_frame_k),
	 .bbox_w_frame_history(bbox_w_frame_history),
	 .bbox_h_frame_history(bbox_h_frame_history),
	 
	 .valid_iou(valid_iou),
	 .iou(iou)  );  
	 
	 
	 
	 
	 
	 
	 
	 
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #50
   @(posedge clk); 
   insert_new_data(100,50, 200,60, 180,55, 200,65, 100, 10, 20, 10 );              // CPU WRITE configurations (TSI master) 
   
   #100 $finish;  
   
//   #100000  $finish;
   
end
   



// ----------------------------------------------------------------------
//                   Clock generator  (Duty cycle 8ns)
// ----------------------------------------------------------------------

   
 always begin
	#2.5 clk = ~clk;
  end

// ----------------------------------------------------------------------
//                   Tasks
// ----------------------------------------------------------------------

 
 task initiate_all;        // sets all tso inputs to '0'.
	  begin
	  clk = 0;
	  start = 0 ;
	  reset_N = 0	;
	  
	   bbox_position_frame_k = 0;	   
	   bbox_position_frame_history = 0;
	   bbox_w_frame_k = 0;
	   bbox_h_frame_k = 0;
	   bbox_w_frame_history = 0;
	   bbox_h_frame_history = 0;
	  
	   #10 reset_N = 1'b1;     // Disable Reset signal.	 
	  end
 endtask



 task insert_new_data ( input logic [`POSITION_INTERSECTION-1:0] x_tl_k, input logic [`POSITION_INTERSECTION-1:0] y_tl_k,input logic [`POSITION_INTERSECTION-1:0] x_br_k, input logic [`POSITION_INTERSECTION-1:0] y_br_k,input logic [`POSITION_INTERSECTION-1:0] x_tl_history, input logic [`POSITION_INTERSECTION-1:0] y_tl_history,input logic [`POSITION_INTERSECTION-1:0] x_br_history, input logic [`POSITION_INTERSECTION-1:0] y_br_history, input logic [`WIDTH_LEN-1:0] width_k,input logic [`HEIGHT_LEN-1:0] height_k,input logic [`WIDTH_LEN-1:0] width_history,input logic [`HEIGHT_LEN-1:0] height_history);
	begin
  		
	   bbox_position_frame_k = {x_tl_k,y_tl_k,x_br_k,y_br_k};  
	   bbox_position_frame_history = {x_tl_history,y_tl_history,x_br_history,y_br_history};
	   bbox_w_frame_k = width_k;
	   bbox_h_frame_k = height_k;
	   bbox_w_frame_history = width_history;
	   bbox_h_frame_history = height_history;
	   
	   #10
		start = 1;	
	   
	   #20
	    start = 0;
	   
	end
	
 endtask	
 
 
 
endmodule  