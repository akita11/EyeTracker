#!/bin/tcl
#// -----------------------------------------------------------------------------
#//  Title         : Extend tcl library
#//  Project       : common
#// -----------------------------------------------------------------------------
#//  File          : extend_tcl_library.tcl
#//  Author        : K.Ishiwatari
#//  Created       : 2017/ 7/ 2
#//  Last modified : 
#// -----------------------------------------------------------------------------
#//  Description   : tcl 
#// -----------------------------------------------------------------------------
#//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
#// -----------------------------------------------------------------------------

#// -----------------------------------------------------------------------------
#       proc GetEnvironment
#// -----------------------------------------------------------------------------
proc GetEnvironment {} {
  set OS       [lindex $::platform(os)       0]
  set ARCH     [lindex $::platform(machine)  0]
  set PLATFORM [lindex $::platform(platform) 0]
}

#// -----------------------------------------------------------------------------
#       proc ReadListFile
#// -----------------------------------------------------------------------------
proc ReadListFile {fname encode eofile} {
    if {[file readable $fname]} {
        set fileid [open $fname "r"]
        fconfigure $fileid -encoding $encode -translation $eofile
        set contents [read $fileid]
        close $fileid
        return $contents
    }
}

#// -----------------------------------------------------------------------------
#       proc ReadFromFileList
#// -----------------------------------------------------------------------------
proc ReadFromFileList {fname} {
    set fname_list [ReadListFile $fname "euc-jp" "lf"]
    foreach fname $fname_list {
        ReadFile $fname
    }
}

#// -----------------------------------------------------------------------------
#       proc ReadFile
#// -----------------------------------------------------------------------------
proc ReadFile {fname} {
    switch -glob -- $fname {
        [/][/]* {
            # Comment
        }
        [#]* {
            # Comment
        }
        default {
            if { [file isfile $fname] == 1} {
                puts "Read file = $fname"
                set ext_fname [file extension $fname]
                switch -glob -- $ext_fname {
                    .v {
                        read_verilog $fname
                    }
                    .xdc {
                        read_xdc $fname
                    }
                    .tcl {
                        source $fname
                    }
                    default {
                    }
                }
            } else {
                puts "File ($fname) does not exist."
            }
        }
    }
}

#// -----------------------------------------------------------------------------
#       proc AddListFile
#// -----------------------------------------------------------------------------
proc AddListFile {fname encode eofile} {
    if {[file readable $fname]} {
        set fileid [open $fname "r"]
        fconfigure $fileid -encoding $encode -translation $eofile
        set contents [read $fileid]
        close $fileid
        return $contents
    }
}

#// -----------------------------------------------------------------------------
#       proc AddFromFileList
#// -----------------------------------------------------------------------------
proc AddFromFileList {fname} {
    set fname_list [ReadListFile $fname "euc-jp" "lf"]
    foreach fname $fname_list {
        ReadFile $fname
    }
}

#// -----------------------------------------------------------------------------
#       proc ReadFile
#// -----------------------------------------------------------------------------
proc AddFile {fname} {
    switch -glob -- $fname {
        [/][/]* {
            # Comment
        }
        [#]* {
            # Comment
        }
        default {
            if { [file isfile $fname] == 1} {
                puts "Read file = $fname"
                set ext_fname [file extension $fname]
                switch -glob -- $ext_fname {
                    .v {
                        read_verilog $fname
                    }
                    .xdc {
                        read_xdc $fname
                    }
                    .tcl {
                        source $fname
                    }
                    default {
                    }
                }
            } else {
                puts "File ($fname) does not exist."
            }
        }
    }
}
