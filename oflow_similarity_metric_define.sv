/*------------------------------------------------------------------------------
 * File          : oflow_similarity_metric_define.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 13, 2024
 * Description   :
 *------------------------------------------------------------------------------*/
`include "/users/epchof/Project/design/work/include_files/oflow_feature_extraction_define.sv"
`include "/users/epchof/Project/design/work/include_files/oflow_calc_iou_define.sv" 


`define WEIGHT_LEN 10 // explenation in ipad, q0.10
`define FEATURE_OF_PREV_LEN 142 // the total length of the features came out of Buffer Mem Unit
`define NUM_OF_METRICS 6
`define INV_NUM_OF_METRICS  6'b0010101   //q0.6, INV=INVERSE 0.1666 
`define D_HISTORY_METRIC 6 // if `D_HISTORY_LEN is 3, 0-5, the maximum result after shift will be 2^5=32, the we need 6 bits

`define AVG_WIDTH_AFTER_OF 46 //Q26.20
// `define AVG_SIMILARITY_METRIC_LEN 44 //Q24.20
`define SCORE_LEN 32
`define ID_LEN 12




`define CM_CONCATE_INDEX `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN+`WIDTH_LEN+`POSITION_CONCATE_LEN+`CM_CONCATE_LEN-1:`ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN+`WIDTH_LEN+`POSITION_CONCATE_LEN
`define POSITION_CONCATE_PREV_INDEX  `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN+`WIDTH_LEN+`POSITION_CONCATE_LEN-1:`ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN+`WIDTH_LEN
`define WIDTH_PREV_INDEX `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN+`WIDTH_LEN-1:`ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN
`define HEIGHT_PREV_INDEX `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN+`HEIGHT_LEN-1:`ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN
`define COLOR1_PREV_INDEX `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN+`COLOR_LEN-1:`ID_LEN+`D_HISTORY_LEN+`COLOR_LEN
`define COLOR2_PREV_INDEX `ID_LEN+`D_HISTORY_LEN+`COLOR_LEN-1:`ID_LEN+`D_HISTORY_LEN
`define D_HISTORY_PREV_INDEX  `ID_LEN+`D_HISTORY_LEN-1:`ID_LEN

// pad metric vector 
`define IOU_PAD_LEN 10 //q0.10
`define WIDTH_PAD_LEN 18 // the maximum difference will be 200 so we want also 8 bits: q8.10
`define HEIGHT_PAD_LEN 18 // the maximum difference will be 200 so we want also 8 bits  q8.10
`define COLOR_PAD_LEN 34 //q24.10
`define D_HISTORY_METRIC_PAD 16 // the len of metric will be +1 the feature:q6.10
`define IOU_PAD_INDEX `IOU_LEN-1:`IOU_LEN-10
//`define AVG_INDEX `AVG_WIDTH_AFTER_OF-1:(`AVG_WIDTH_AFTER_OF-`SCORE_LEN)
`define AVG_INDEX `AVG_WIDTH_AFTER_OF-1-10:3


`define COUNTER_SIZE 4