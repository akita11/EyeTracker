# // -----------------------------------------------------------------------------
# //  Title         : Generate IP design for DIV_28_20
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : generate_IP_design_DIV_28_20.tcl
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 6/14
# //  Last modified : 
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file 
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

# /* ---- Main Routine ---- */
create_ip -name div_gen -vendor xilinx.com -library ip -version 5.1 -module_name DIV_28_20

set_property -dict [list CONFIG.dividend_and_quotient_width {28} CONFIG.divisor_width {20} \
             CONFIG.operand_sign {Unsigned} CONFIG.divide_by_zero_detect {true} CONFIG.ACLKEN {true} CONFIG.ARESETN {true} \
             CONFIG.remainder_type {Fractional} CONFIG.fractional_width {20} CONFIG.latency {50}] [get_ips DIV_28_20]

generate_target all [get_ips DIV_28_20] -force
synth_ip [get_ips DIV_28_20]
