/*------------------------------------------------------------------------------
 * File          : oflow_fsm_read.sv
 * Project       : RTL
 * Author        : epchof
 * Creation date : Jun 30, 2024
 * Description   :
 *------------------------------------------------------------------------------*/

`define ROW_LEN 4 //The maximum rows of each pe mem is 11
`define PE_LEN 5 // There are 24 PEs
`define SET_LEN 4 //The maximum sets: 256/PE_NUM=11, need 4 bits: 2^4 = 16 > 11
`define PE_NUM 24 // There are 24 PEs
`define DATA_OUT_NUM 4 // Num of the dataouts from the mux
`define REMAINDER_LEN 2 // remainder=1 or2 or 3
`define REMAIN_BBOX_LEN 8 // each set we will reduce PE_NUM =24.which will be the reminder in each set
`define MAX_BBOXES_PER_FRAME 256
`define ID_LEN 12
//in interface in similarity metric
`define DATA_TO_PE_WIDTH (`FEATURE_OF_PREV_LEN+`D_HISTORY_LEN ) //142+3=145
