# // -----------------------------------------------------------------------------
# //  Title         : Design Constraint file for EyeTracker
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : TOP_bitstream.tcl
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 1/ 1
# //  Last modified : 
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file for bitstream
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

# // -----------------------------------------------------------------------------
# //     for Bitstream (tcl.pre)
# // -----------------------------------------------------------------------------

# /* ----- Allow unconstrainted Pins ----- */
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

# /* ----- Resolve Rule violation (NSTD-1) AR# 56354 ----- */
set_property SEVERITY {Warning} [get_drc_check NSTD-1]
set_property SEVERITY {Warning} [get_drc_check UCIO-1]
