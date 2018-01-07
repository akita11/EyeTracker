// -----------------------------------------------------------------------------
//  Title         : SDF annotation
//  Project       : Common Library
// -----------------------------------------------------------------------------
//  File          : SDF.v
//  Author        : K.Ishiwatari
//  Created       : 2018/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Annotate SDF file
// -----------------------------------------------------------------------------
//  Copyright (C) 2018 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ps/1ps

module SDF (
);
    initial begin
        $sdf_annotate("./sdf/sdf_file.sdf", SIM_TOP.m_TOP,,"./log/sdf_annotation.log");
    end

endmodule
