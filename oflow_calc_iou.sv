/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

module oflow_calc_iou #() (input logic clk,
	input logic reset_N	,

	 input logic[43:0] bbox_position_frame_k	,   // {X_TL, Y_TL, X_BR, Y_BR}
	 input logic[43:0] bbox_position_frame_history, // {X_TL, Y_TL, X_BR, Y_BR}
	 input logic[10:0] bbox_w_frame_k,
	 input logic[10:0] bbox_h_frame_k,
	 input logic[10:0] bbox_w_frame_history,
	 input logic[10:0] bbox_h_frame_history,
	 
	
	 output logic[21:0] iou  ); 





typedef enum {idle_st,coordinate_st,intersection_st,iou_st} sm_type;
sm_type current_state;
sm_type next_state;

	
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

   logic [10:0] x_tl_intersection;
   logic [10:0] x_br_intersection;
   logic [10:0] y_tl_intersection;
   logic [10:0] y_br_intersection;
   logic [21:0] Intersection;
   logic [21:0] size_length_k;
   logic [21:0] size_length_history;
	logic [3:0] counter;



// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk, posedge reset_N) begin
		if (reset_N == 1'b1) begin
			current_state <= #1 idle_st;
		end
		else begin
			current_state <= #1 next_state;
		end
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk, posedge reset_N) begin
		if (reset_N == 1'b1 || next_state == idle_st) begin
			counter <= #1 4'd0;
		end
		else begin
			counter <= #1 counter+1;
		end
	end
	
	
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	
	case (current_state)
		idle_st: begin
				next_state = coordinate_st;	
		end
		
		coordinate_st: begin
			x_tl_intersection = (bbox_position_frame_k [43:33] >bbox_position_frame_history [43:33]) ? bbox_position_frame_k [43:33] : bbox_position_frame_history [43:33]; 
			y_tl_intersection = (bbox_position_frame_k [32:22] >bbox_position_frame_history [32:22]) ? bbox_position_frame_k [32:22] : bbox_position_frame_history [32:22]; 
			x_br_intersection = (bbox_position_frame_k [21:11] <bbox_position_frame_history [21:11]) ? bbox_position_frame_k [21:11] : bbox_position_frame_history [21:11]; 
			y_br_intersection = (bbox_position_frame_k [10:0] <bbox_position_frame_history [10:0]) ? bbox_position_frame_k [10:0] : bbox_position_frame_history [10:0]; 
			size_length_k =  bbox_w_frame_k*bbox_h_frame_k;
			size_length_history = bbox_w_frame_history*bbox_h_frame_history;
			next_state = intersection_st;
		end
		
		intersection_st: begin 
				if ((x_br_intersection < x_tl_intersection) || (y_br_intersection < y_tl_intersection)) Intersection = 22'd0;
				else Intersection = (x_br_intersection - x_tl_intersection) * (y_br_intersection - y_tl_intersection);
				if (counter == 4'd4)
					next_state = iou_st;
		end
		
		iou_st: begin 
			iou = 1 - Intersection / (size_length_k + size_length_history - Intersection);
			if (counter == 4'd8)
				next_state = idle_st;
		end
	endcase
end

	
	
	
endmodule
	
	
	
	
/*	
	 x_tl_intersection_wire <= (bbox_position_frame_k [43:33] >bbox_position_frame_history [43:33]) ? bbox_position_frame_k [43:33] : bbox_position_frame_history [43:33]; 
		y_tl_intersection_wire <= (bbox_position_frame_k [32:22] >bbox_position_frame_history [32:22]) ? bbox_position_frame_k [32:22] : bbox_position_frame_history [32:22]; 
		x_br_intersection_wire <= (bbox_position_frame_k [21:11] <bbox_position_frame_history [21:11]) ? bbox_position_frame_k [21:11] : bbox_position_frame_history [21:11]; 
		y_br_intersection_wire <= (bbox_position_frame_k [10:0] <bbox_position_frame_history [10:0]) ? bbox_position_frame_k [10:0] : bbox_position_frame_history [10:0]; 
		y_br_intersection_wire <= (bbox_position_frame_k [10:0] <bbox_position_frame_history [10:0]) ? bbox_position_frame_k [10:0] : bbox_position_frame_history [10:0]; 
		size_length_k_wire <= bbox_w_frame_k *bbox_h_frame_k; 
		size_length_history_wire <= bbox_w_frame_history* bbox_h_frame_history; 
	
	
	
	
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

   logic [10:0] x_tl_intersection;
   logic [10:0] x_br_intersection;
   logic [10:0] y_tl_intersection;
   logic [10:0] y_tl_intersection;
   logic [21:0] Intersection;
   logic [21:0] Union;
   logic [21:0] size_length_k;
   logic [21:0] size_length_history;
   // -----------------------------------------------------------       
   //                  calc intersection coordinate
   // -----------------------------------------------------------  
   always_ff @(posedge clk or negedge resetN)   
   begin
	   if (!resetN) begin 
		x_tl_intersection <= 11'd0;
		x_br_intersection <= 11'd0;
		y_tl_intersection <= 11'd0;
		y_tl_intersection <= 11'd0;
		Intersection <= 21'd0;
		Union <= 21'd0;
		size_length_k <= 21'd0;
		size_length_history <= 21'd0;
	   end
	   else begin 
		x_tl_intersection <= (bbox_position_frame_k [43:33] >bbox_position_frame_history [43:33]) ? bbox_position_frame_k [43:33] : bbox_position_frame_history [43:33]; 
		y_tl_intersection <= (bbox_position_frame_k [32:22] >bbox_position_frame_history [32:22]) ? bbox_position_frame_k [32:22] : bbox_position_frame_history [32:22]; 
		x_br_intersection <= (bbox_position_frame_k [21:11] <bbox_position_frame_history [21:11]) ? bbox_position_frame_k [21:11] : bbox_position_frame_history [21:11]; 
		y_br_intersection <= (bbox_position_frame_k [10:0] <bbox_position_frame_history [10:0]) ? bbox_position_frame_k [10:0] : bbox_position_frame_history [10:0]; 
		y_br_intersection <= (bbox_position_frame_k [10:0] <bbox_position_frame_history [10:0]) ? bbox_position_frame_k [10:0] : bbox_position_frame_history [10:0]; 
		size_length_k <= bbox_w_frame_k *bbox_h_frame_k; 
		size_length_history <= bbox_w_frame_history* bbox_h_frame_history; 
		end
	end



   // -----------------------------------------------------------       
   //                  calc intersection 
   // -----------------------------------------------------------  
   always_ff @(posedge clk_divideby2 or negedge resetN)   
   begin
	   if (!resetN) begin 
		Intersection <= 21'd0;
	   end
	   else begin 
		if ()
		end
	end


endmodule
*/
