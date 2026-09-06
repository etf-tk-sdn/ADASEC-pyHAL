# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: AGPL-3.0-or-later

proc protocol_error {message} {
    puts "@ERR $message"
    flush stdout
}

set master_paths [get_service_paths master]
if {[llength $master_paths] == 0} {
    protocol_error "NO_MASTER"
    exit 1
}

set master_path ""
if {[info exists ::env(ADASEC_MASTER_SELECTOR)] &&
    $::env(ADASEC_MASTER_SELECTOR) ne ""} {
    set selector $::env(ADASEC_MASTER_SELECTOR)
    foreach candidate $master_paths {
        if {$candidate eq $selector || [string first $selector $candidate] >= 0} {
            if {$master_path ne ""} {
                protocol_error "AMBIGUOUS_MASTER_SELECTOR"
                exit 1
            }
            set master_path $candidate
        }
    }
    if {$master_path eq ""} {
        protocol_error "MASTER_NOT_FOUND"
        exit 1
    }
} elseif {[llength $master_paths] == 1} {
    set master_path [lindex $master_paths 0]
} else {
    protocol_error "MULTIPLE_MASTERS_SET_ADASEC_MASTER_SELECTOR"
    foreach candidate $master_paths {
        puts "@MASTER $candidate"
    }
    flush stdout
    exit 1
}

if {[catch {
    set claimed_master [claim_service master $master_path adasec_pyhal]
} claim_error]} {
    protocol_error "CLAIM_FAILED $claim_error"
    exit 1
}

puts "@READY $master_path"
flush stdout

while {[gets stdin line] >= 0} {
    set tokens [split [string trim $line]]
    if {[llength $tokens] == 0 || [lindex $tokens 0] eq ""} {
        continue
    }

    set command [string toupper [lindex $tokens 0]]
    if {$command eq "READ32"} {
        if {[llength $tokens] != 2} {
            protocol_error "SYNTAX READ32_ADDRESS"
            continue
        }
        if {[catch {
            set address [expr {wide([lindex $tokens 1])}]
            set result [master_read_32 $claimed_master $address 1]
            set value [lindex $result 0]
            after 1
        } read_error]} {
            protocol_error "READ_FAILED $read_error"
        } else {
            puts [format "@DATA 0x%08X" $value]
            flush stdout
        }
    } elseif {$command eq "WRITE32"} {
        if {[llength $tokens] != 3} {
            protocol_error "SYNTAX WRITE32_ADDRESS_VALUE"
            continue
        }
        if {[catch {
            set address [expr {wide([lindex $tokens 1])}]
            set value [expr {wide([lindex $tokens 2])}]
            master_write_32 $claimed_master $address $value
            after 1
        } write_error]} {
            protocol_error "WRITE_FAILED $write_error"
        } else {
            puts "@OK"
            flush stdout
        }
    } elseif {$command eq "QUIT"} {
        puts "@OK"
        flush stdout
        break
    } else {
        protocol_error "UNKNOWN_COMMAND <$command>"
    }
}

close_service master $claimed_master
