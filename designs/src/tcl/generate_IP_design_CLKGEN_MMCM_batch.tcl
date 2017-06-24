# // -----------------------------------------------------------------------------
# //  Title         : Generate IP design for CLKGEN_MMCM
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : generate_IP_design_CLKGEN_MMCM.tcl
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 1/ 1
# //  Last modified : 
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file 
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.3 -module_name CLKGEN_MMCM
set_property -dict [list CONFIG.USE_MIN_POWER {true} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.RESET_PORT {resetn} \
             CONFIG.PRIM_IN_FREQ {50} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
             CONFIG.JITTER_SEL {No_Jitter} CONFIG.CLKIN1_JITTER_PS {200.0} CONFIG.CLKOUT1_DRIVES {BUFGCE} \
             CONFIG.CLKOUT2_DRIVES {BUFGCE} CONFIG.CLKOUT3_DRIVES {BUFGCE} CONFIG.CLKOUT4_DRIVES {BUFGCE} \
             CONFIG.CLKOUT5_DRIVES {BUFGCE} CONFIG.CLKOUT6_DRIVES {BUFGCE} CONFIG.CLKOUT7_DRIVES {BUFGCE} \
             CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
             CONFIG.MMCM_DIVCLK_DIVIDE {2} CONFIG.MMCM_CLKFBOUT_MULT_F {24.125} CONFIG.MMCM_CLKIN1_PERIOD {20.0} \
             CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.125} CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.5} \
             CONFIG.CLKOUT1_JITTER {437.668} CONFIG.CLKOUT1_PHASE_ERROR {333.440}] [get_ips CLKGEN_MMCM]
generate_target all [get_ips CLKGEN_MMCM] -force
synth_ip [get_ips CLKGEN_MMCM]
