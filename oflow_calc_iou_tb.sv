/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou_tb.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 19, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_calc_iou_tb #() ();

   
// -----------------------------------------------------------       
//                  Registers & Wires
// -----------------------------------------------------------  

		   
	 logic clk;
	 logic reset_N;

	 logic[43:0] bbox_position_frame_k;   // {X_TL, Y_TL, X_BR, Y_BR}
	 logic[43:0] bbox_position_frame_history; // {X_TL, Y_TL, X_BR, Y_BR}
	 logic[10:0] bbox_w_frame_k;
	 logic[10:0] bbox_h_frame_k;
	 logic[10:0] bbox_w_frame_history;
	 logic[10:0] bbox_h_frame_history;
	 logic[21:0] iou;
// ----------------------------------------------------------------------
//                   Instantiation
// ----------------------------------------------------------------------



oflow_calc_iou oflow_calc_iou  (.clk(clk),
	.reset_N(reset_N),

	 .bbox_position_frame_k(bbox_position_frame_k)	,   // {X_TL, Y_TL, X_BR, Y_BR}
	 .bbox_position_frame_history(bbox_position_frame_history), // {X_TL, Y_TL, X_BR, Y_BR}
	 .bbox_w_frame_k(bbox_w_frame_k),
	 .bbox_h_frame_k(bbox_h_frame_k),
	 .bbox_w_frame_history(bbox_w_frame_history),
	 .bbox_h_frame_history(bbox_h_frame_history),
	 
	 .iou(iou)  );  
	 
	 
	 
	 
	 
	 
	 
	 
// ----------------------------------------------------------------------
//                   Test Pattern
// ----------------------------------------------------------------------


initial 
begin
   initiate_all;                                 // Initiates all input signals to '0' and open necessary files
	 
   #100 
   @(posedge clk); 
   insert_new_data;              // CPU WRITE configurations (TSI master) 
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
	  reset_N = 1	;
	  
	   bbox_position_frame_k = 0;	   
	   bbox_position_frame_history = 0;
	   bbox_w_frame_k = 0;
	   bbox_h_frame_k = 0;
	   bbox_w_frame_history = 0;
	   bbox_h_frame_history = 0;
	  
	   #2 reset_N = 1'b0;     // Disable Reset signal.	 
	  end
 endtask



 task insert_new_data;
	begin
  
	   bbox_position_frame_k = 44'b00111110100_00011111010_01000001000_00100011000;  
	   bbox_position_frame_history = 44'b01111101000_10010110000_01111110010_10010111111;
	   bbox_w_frame_k = 11'b00000010100;
	   bbox_h_frame_k = 11'b0000011110;
	   bbox_w_frame_history = 11'b00000001010;
	   bbox_h_frame_history = 11'b00000001111;
	   
	 end
 	endtask	
 
 
 
endmodule  