/*------------------------------------------------------------------------------
 * File          : all_mem.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 23, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"

/*mem mem(.clk(clk),
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
	);*/
//<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=
 // Function : Synchronous read write RAM
 // Coder    : Deepak Kumar Tala
 // Date     : 1-Nov-2005
 //<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=
 module all_mem #(parameter NUM_OF_MEM = 6,
				   parameter DATA_WIDTH = 290,
				   parameter DATA_INST_WIDTH = 64,
				   parameter ADDR_WIDTH = 8,
				   parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
 input  logic                  clk       , // Clock Input
 input logic 					reset_N,
 input  logic [ADDR_WIDTH-1:0] address_0 , // address_0 Input
 input  logic [DATA_WIDTH-1:0] data_in_0    , // data_in_0 
 input  logic                  csb_0      , // Chip Select
 input  logic                  web_0      , // Write Enable/Read Enable
 input  logic                  oeb_0      , // Output Enable
 input  logic [ADDR_WIDTH-1:0] address_1 , // address_1 Input
 input  logic [DATA_WIDTH-1:0] data_in_1    , // data_in_1 
 input  logic                  csb_1      , // Chip Select
 input  logic                  web_1      , // Write Enable/Read Enable
 input  logic                  oeb_1     ,   // Output Enable
 
 output  logic [DATA_WIDTH-1:0] data_out_0    , // data_out_0 
 output  logic [DATA_WIDTH-1:0] data_out_1    // data_out_1
 ); 
 //--------------Internal variables---------------- 
 logic [DATA_WIDTH-1:0] data_0_out ; 
 logic [DATA_WIDTH-1:0] data_1_out ;
 logic [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];

 //--------------Code Starts Here------------------
//for write to mem
//mem_inst 0-2 is mem_0||mem_inst 3-5 is mem_1

logic [DATA_INST_WIDTH-1:0] data_in_inst_0 [NUM_OF_MEM];
logic [DATA_INST_WIDTH-1:0] data_in_inst_1 [NUM_OF_MEM];
//for read from mem
logic [DATA_INST_WIDTH-1:0] data_out [NUM_OF_MEM];
logic [DATA_INST_WIDTH-1:0] data_out_dont_care [NUM_OF_MEM];


//in write mode we write to 4 cell-2 rows.


//one row:
//id+cm_concate
assign data_in_inst_0[0] = {data_in_0[(DATA_WIDTH/2)+`ID_LEN-1:(DATA_WIDTH/2)],data_in_0[DATA_WIDTH-1:DATA_WIDTH-`CM_CONCATE_LEN]};//bbox left
assign data_in_inst_0[0+(NUM_OF_MEM/2)] ={data_in_0[`ID_LEN-1:0],data_in_0[(DATA_WIDTH/2)-1:(DATA_WIDTH/2)-`CM_CONCATE_LEN]};//bbox right mean we take offset of (NUM_OF_MEM/2) cause 0-2 :left bbox ,3-5:right bbox
  

//position concate
assign data_in_inst_0[1] = data_in_0[DATA_WIDTH-`CM_CONCATE_LEN-1-:(`POSITION_CONCATE_LEN-1)];
assign data_in_inst_0[1+(NUM_OF_MEM/2)] = data_in_0[(DATA_WIDTH/2)-`CM_CONCATE_LEN-1-:(`POSITION_CONCATE_LEN-1)];

//width,height,color1,color2
assign data_in_inst_0[2] = data_in_0[DATA_WIDTH-`CM_CONCATE_LEN-`POSITION_CONCATE_LEN-1:`ID_LEN+(DATA_WIDTH/2)];
assign data_in_inst_0[2+(NUM_OF_MEM/2)] = data_in_0[(DATA_WIDTH/2)-`CM_CONCATE_LEN-`POSITION_CONCATE_LEN-1:`ID_LEN];



//second row:
//id+cm_concate
//id+cm_concate
assign data_in_inst_1[0] = {data_in_1[(DATA_WIDTH/2)+`ID_LEN-1:(DATA_WIDTH/2)],data_in_1[DATA_WIDTH-1:DATA_WIDTH-`CM_CONCATE_LEN]};
assign data_in_inst_1[0+(NUM_OF_MEM/2)] ={data_in_1[`ID_LEN-1:0],data_in1[(DATA_WIDTH/2)-1:(DATA_WIDTH/2)-`CM_CONCATE_LEN]};
  

//position concate
assign data_in_inst_1[1] = data_in_1[DATA_WIDTH-`CM_CONCATE_LEN-1-:(`POSITION_CONCATE_LEN-1)];
assign data_in_inst_1[1+(NUM_OF_MEM/2)] = data_in_1[(DATA_WIDTH/2)-`CM_CONCATE_LEN-1-:(`POSITION_CONCATE_LEN-1)];

//width,height,color1,color2
assign data_in_inst_1[2] = data_in_1[DATA_WIDTH-`CM_CONCATE_LEN-`POSITION_CONCATE_LEN-1:`ID_LEN+(DATA_WIDTH/2)];
assign data_in_inst_1[2+(NUM_OF_MEM/2)] = data_in_1[(DATA_WIDTH/2)-`CM_CONCATE_LEN-`POSITION_CONCATE_LEN-1:`ID_LEN];


//in read mode we read from one row 

assign data_out_0 ={data_out[0][`CM_CONCATE_LEN-1:0],data_out[0+1][`POSITION_CONCATE_LEN-1:0],data_out[0+2],data_out[0][`CM_CONCATE_LEN+`ID_LEN-1 -:(`ID_LEN-1)]       
					,data_out[0+3][`CM_CONCATE_LEN-1:0],data_out[0+1+3][`POSITION_CONCATE_LEN-1:0],data_out[0+2+3],data_out[0+3][`CM_CONCATE_LEN+`ID_LEN-1 -:(`ID_LEN-1)]} ;


assign data_out_1 = '0;

 
genvar i;

generate 
	for  ( i=0; i < NUM_OF_MEM ; i+=1) begin 
		
		mem_256x64 mem_inst(
		.clk(clk)
		.reset_N(reset_N),
		.data_in_0(data_in_inst_0[i]),
		.data_out_0(data_out[i]),
		.addr_0(address_0),
		.web_0(web_0),
		.ceb_0(1'b0),//active low
		.csb_0(csb_0),
		.oeb_0(oeb_0),
		.data_in_1(data_in_inst_1),
		.data_out_1(data_out_dont_care[i]),
		.addr_1(address_1),
		.web_1(web_1),
		.ceb_1(1'b0//active low
		.csb_1(csb_1),
		.oeb_1(oeb_1)
		);
		
	end
endgenerate
 
endmodule