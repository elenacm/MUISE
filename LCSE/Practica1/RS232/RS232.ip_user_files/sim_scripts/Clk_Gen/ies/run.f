-makelib ies_lib/xpm -sv \
  "C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../RS232.srcs/sources_1/ip/Clk_Gen/Clk_Gen_clk_wiz.v" \
  "../../../../RS232.srcs/sources_1/ip/Clk_Gen/Clk_Gen.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

