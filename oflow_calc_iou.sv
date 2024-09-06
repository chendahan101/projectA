/*------------------------------------------------------------------------------
 * File          : oflow_calc_iou.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jan 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_calc_iou_define.sv"


module oflow_calc_iou #() (input logic clk,
	input logic reset_N	,
	input logic start	,

	 input logic[`BBOX_POSITION_FRAME-1:0] bbox_position_frame_k	,   // {X_TL, Y_TL, X_BR, Y_BR}
	 input logic[`BBOX_POSITION_FRAME-1:0] bbox_position_frame_history, // {X_TL, Y_TL, X_BR, Y_BR}
	 input logic[`WIDTH_LEN-1:0] bbox_w_frame_k,
	 input logic[`HEIGHT_LEN-1:0] bbox_h_frame_k,
	 input logic[`WIDTH_LEN-1:0] bbox_w_frame_history,
	 input logic[`HEIGHT_LEN-1:0] bbox_h_frame_history,
	 
	 output logic valid_iou ,
	 output logic[`IOU_LEN-1:0] iou  ); 





typedef enum {idle_st,coordinate_st,intersection_area_st,iou_st} sm_type;
sm_type current_state;
sm_type next_state;

	
// -----------------------------------------------------------       
//                  logicisters & Wires
// -----------------------------------------------------------  

   logic [`POSITION_INTERSECTION-1:0] x_tl_intersection;
   logic [`POSITION_INTERSECTION-1:0] x_br_intersection;
   logic [`POSITION_INTERSECTION-1:0] y_tl_intersection;
   logic [`POSITION_INTERSECTION-1:0] y_br_intersection;
   logic [`INTERSECTION-1:0] Intersection;
   logic [`SIZE_LENGTH-1:0] size_length_k;
   logic [`SIZE_LENGTH-1:0] size_length_history;
   logic [`COUNTER_LEN-1:0] counter;
   logic [`BBOX_POSITION_FRAME-1:0] temp_iou;

	logic start_DW_div_seq;
	logic done_DW_div_seq, divide_by_0, remainder;
	logic [`INTERSECTION*2-1:0] a;
	logic [`INTERSECTION-1:0] b;

// -----------------------------------------------------------       
//                 Instantiations
// -----------------------------------------------------------  
   
   DW_div_seq # ( .a_width(`INTERSECTION*2), .b_width(`INTERSECTION) ) DW_div_seq ( .clk(clk) , .rst_n(reset_N), .hold(1'b0)
	   , .start(start_DW_div_seq), .a(a),   .b(b) , .complete(done_DW_div_seq), .divide_by_0(divide_by_0), .quotient(temp_iou), .remainder(remainder) );
   
   
// -----------------------------------------------------------       
//                FSM synchronous procedural block.	
// -----------------------------------------------------------
	always_ff @(posedge clk, posedge reset_N) begin
		if (!reset_N ) begin
			current_state <= #1 idle_st;
		end
		else begin
			current_state <= #1 next_state;
		end
	end
//--------------------counter---------------------------------	
	 always_ff @(posedge clk, posedge reset_N) begin
		if (!reset_N  || next_state == idle_st || next_state != current_state) begin
			counter <= #1 4'd0;
		end
		else begin
			counter <= #1 counter + 1;
		end
	end
	
	
// -----------------------------------------------------------       
//						FSM – Async Logic
// -----------------------------------------------------------	
always_comb begin
	next_state = current_state;
	valid_iou = 1'b0;
	start_DW_div_seq = 1'b0;
	case (current_state)
		idle_st: begin
				next_state = start ? coordinate_st:idle_st;	
		end
		
		coordinate_st: begin
			x_tl_intersection = max (bbox_position_frame_k[`X_TL_MSB_IN_BBOX-1:`X_TL_MSB_IN_BBOX-`POSITION_INTERSECTION],bbox_position_frame_history [`X_TL_MSB_IN_BBOX-1:`X_TL_MSB_IN_BBOX-`POSITION_INTERSECTION]); 
			y_tl_intersection = max(bbox_position_frame_k [`Y_TL_MSB_IN_BBOX-1:`Y_TL_MSB_IN_BBOX-`POSITION_INTERSECTION] ,bbox_position_frame_history [`Y_TL_MSB_IN_BBOX-1:`Y_TL_MSB_IN_BBOX-`POSITION_INTERSECTION]);
			x_br_intersection = min(bbox_position_frame_k [`X_BR_MSB_IN_BBOX-1:`X_BR_MSB_IN_BBOX-`POSITION_INTERSECTION] ,bbox_position_frame_history [`X_BR_MSB_IN_BBOX-1:`X_BR_MSB_IN_BBOX-`POSITION_INTERSECTION]);
			y_br_intersection = min(bbox_position_frame_k [`Y_BR_MSB_IN_BBOX-1:0] ,bbox_position_frame_history [`Y_BR_MSB_IN_BBOX-1:0]) ;
			size_length_k =  bbox_w_frame_k*bbox_h_frame_k;
			size_length_history = bbox_w_frame_history*bbox_h_frame_history;
			next_state = intersection_area_st;
		end
		
		intersection_area_st: begin 
				if ((x_br_intersection < x_tl_intersection) || (y_br_intersection < y_tl_intersection)) Intersection = 22'd0;
				else Intersection = (x_br_intersection - x_tl_intersection) * (y_br_intersection - y_tl_intersection);
				a = (Intersection << 22);
				b = (size_length_k + size_length_history - Intersection);
				if (counter == 2) begin // we need 3 but counter start from 0 //this counter for the mul in line 108
					start_DW_div_seq = 1'b1;
					next_state = iou_st;
				end	
					
		end
		
		iou_st: begin
			
			
			//a = (Intersection << 22);
			//b = (size_length_k + size_length_history - Intersection);
			//if(counter == 0)
			//	start_DW_div_seq = 1'b1;
			//temp_iou = ((Intersection )<< 22) / (size_length_k + size_length_history - Intersection); // its ok to sub 22 bits from 16 bits because the 22 bits is less than 16 bits actually
			iou = {22{1'b1}} - temp_iou[21:0];  // iou q0.22
			
			// iou = 1 - (Intersection / (size_length_k + size_length_history - Intersection));
			if (counter == 3) begin// counter start fom 0
				next_state = idle_st;
				valid_iou = 1'b1;
			end	
		end
	endcase
end

// -----------------------------------------------------------       
//              Functions	
// -----------------------------------------------------------
function [`POSITION_INTERSECTION-1:0] max (input [`POSITION_INTERSECTION-1:0] a,input [`POSITION_INTERSECTION-1:0] b);
	max = (a>b) ? a:b;
endfunction
function [`POSITION_INTERSECTION-1:0] min (input [`POSITION_INTERSECTION-1:0] a,input [`POSITION_INTERSECTION-1:0] b);
	min = (a<b) ? a:b;
endfunction
	
	
endmodule
	
	