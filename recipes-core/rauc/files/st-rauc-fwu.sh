#!/bin/sh
# RAUC custom bootloader backend for STM32MP (FWU metadata V2 based A/B update).
# Interface: https://rauc.readthedocs.io/en/latest/integration.html#custom
#
#   get-primary                     print primary slot bootname
#   set-primary <bootname>          make <bootname> the primary slot
#   get-state <bootname>            print "good" or "bad"
#   set-state <bootname> <state>    set state ("good" or "bad") of <bootname>
#   get-current                     print booted slot bootname
#
# Must exit 0 on success and non-zero on failure.
# Slot bootname A/B maps to FWU bank 0/1.

FWUMDATA=fwumdata

error() {
    echo "st-rauc-fwu: $*" >&2
    exit 1
}

bootname_to_bank() {
    case "$1" in
        A) echo 0 ;;
        B) echo 1 ;;
        *) return 1 ;;
    esac
}

bank_to_bootname() {
    case "$1" in
        0) echo A ;;
        1) echo B ;;
        *) return 1 ;;
    esac
}

# Print metadata summary/details, failing if metadata cannot be read
mdata() {
    out=$("$FWUMDATA" "$@" 2>&1) || error "fwumdata $* failed: $out"
    echo "$out"
}

get_active_bank() {
    mdata | awk '$1 == "Active" && $2 == "Index:" { print $3; exit }'
}

get_bank_state() {
    mdata | awk -v bank="$1" '$1 == "Bank" && $2 == bank ":" { print $3; exit }'
}

get_nimages() {
    mdata -l | awk '$1 == "Number" && $3 == "Images:" { print $4; exit }'
}

get_current() {
    for param in $(cat /proc/cmdline); do
        case "$param" in
            rauc.slot=*) echo "${param#rauc.slot=}"; return 0 ;;
        esac
    done
    return 1
}

cmd=$1

case "$cmd" in
    get-primary)
        bank=$(get_active_bank)
        bank_to_bootname "$bank" || error "invalid active bank '$bank'"
        ;;

    set-primary)
        bank=$(bootname_to_bank "$2") || error "invalid bootname '$2'"
        current=$(get_current) || error "cannot determine booted slot"
        prev=$(bootname_to_bank "$current") || error "invalid booted slot '$current'"
        nimages=$(get_nimages)
        [ -n "$nimages" ] || error "cannot determine number of images"

        # Clear acceptance of all images so that the new bank boots in trial
        # mode (bootcount enabled) until it is marked good.
        i=0
        while [ "$i" -lt "$nimages" ]; do
            mdata -i "$i" -b "$bank" -C > /dev/null
            i=$((i + 1))
        done
        mdata -a "$bank" -p "$prev" -s "$bank" valid > /dev/null
        ;;

    get-state)
        bank=$(bootname_to_bank "$2") || error "invalid bootname '$2'"
        state=$(get_bank_state "$bank")
        case "$state" in
            accepted|valid) echo "good" ;;
            invalid) echo "bad" ;;
            *) error "unknown state '$state' for bank $bank" ;;
        esac
        ;;

    set-state)
        bank=$(bootname_to_bank "$2") || error "invalid bootname '$2'"
        case "$3" in
            # Accepting the bank also accepts all its images and leaves trial mode
            good) mdata -s "$bank" accepted > /dev/null ;;
            bad) mdata -s "$bank" invalid > /dev/null ;;
            *) error "invalid state '$3'" ;;
        esac
        ;;

    get-current)
        get_current || error "cannot determine booted slot"
        ;;

    *)
        error "unsupported command '$cmd'"
        ;;
esac

exit 0
