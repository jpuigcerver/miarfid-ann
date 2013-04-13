#!/bin/bash

set -e
shopt -s extglob
export LC_NUMERIC=C

# Default parameters
METHOD=( "MULTI" "ONE-VS-REST" )
T_PARAM=( 0 1 2 3 )
D_PARAM=( 1 )
G_PARAM=( 1 )
S_PARAM=( 1 )
R_PARAM=( 1 )
C_PARAM=( DEFAULT )
MAXITER=1000000
TRAIN=( `ls Data/sat6c.tra.norm.svmlight.train+([0-9])` )
VALID=( `ls Data/sat6c.tra.norm.svmlight.valid+([0-9])` )
ODIR=

function help () {
    echo "Usage: `basename $0`"
}

# Parse arguments
while [ "${1:0:1}" == "-" ]; do
    case "$1" in
	"-h")
	    help
	    exit 0
	    ;;
	"-o")
	    ODIR="$2"; shift 2;
	    ;;
	"-tr")
	    shift 1;
	    TRAIN=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		TRAIN=( ${TRAIN[@]} "$1" ); shift 1;
	    done
	    ;;
	"-va")
	    shift 1;
	    VALID=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		VALID=( ${VALID[@]} "$1" ); shift 1;
	    done
	    ;;
	"-m")
	    shift 1;
	    METHOD=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		METHOD=( ${METHOD[@]} "$1" ); shift 1;
	    done
	    ;;
	"-t")
	    shift 1;
	    T_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		T_PARAM=( ${T_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	"-c")
	    shift 1;
	    C_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		C_PARAM=( ${C_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	"-d")
	    shift 1;
	    D_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		D_PARAM=( ${D_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	"-g")
	    shift 1;
	    G_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		G_PARAM=( ${G_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	"-s")
	    shift 1;
	    S_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		S_PARAM=( ${S_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	"-r")
	    shift 1;
	    R_PARAM=( )
	    while [ "${1:0:1}" != "-" -a $# -gt 0 ]; do
		R_PARAM=( ${R_PARAM[@]} "$1" ); shift 1;
	    done
	    ;;
	*)
	    echo "Unknown option: $1" >&2; exit 1;
    esac
done

# Run experiments
for m in ${METHOD[@]}; do
    case "$m" in
	"ONE-VS-REST")
	    RUN_METHOD="./Run-One-vs-Rest.sh"
	    ;;
	"MULTI")
	    RUN_METHOD="./Run-Multiclass.sh"
	    ;;
	*)
	    echo "Unknown method: $m" >&2; exit 1;
    esac
    for t in ${T_PARAM[@]}; do
	case $t in
	    0)
		for c in ${C_PARAM[@]}; do
		    copt="-c $c"
		    [ $c = "DEFAULT" ] && { copt=""; }
		    ${RUN_METHOD} -tr ${TRAIN[@]} -va ${VALID[@]} \
			-o $ODIR -t $t -# $MAXITER ${copt}
		done
		;;
	    1)
		for c in ${C_PARAM[@]}; do
		    copt="-c $c"
		    [ $c = "DEFAULT" ] && { copt=""; }
		    for d in ${D_PARAM[@]}; do
			for s in ${S_PARAM[@]}; do
			    for r in ${R_PARAM[@]}; do
				${RUN_METHOD} -tr ${TRAIN[@]} \
				    -va ${VALID[@]} -o $ODIR -t $t \
				    -# $MAXITER ${copt} -d $d -s $s -r $r
			    done
			done
		    done
		done
		;;
	    2)
		for c in ${C_PARAM[@]}; do
		    copt="-c $c"
		    [ $c = "DEFAULT" ] && { copt=""; }
		    for g in ${G_PARAM[@]}; do
			${RUN_METHOD} -tr ${TRAIN[@]} \
			    -va ${VALID[@]} -o $ODIR -t $t \
			    -# $MAXITER ${copt} -g $g
		    done
		done
		;;
	    3)
		for c in ${C_PARAM[@]}; do
		    copt="-c $c"
		    [ $c = "DEFAULT" ] && { copt=""; }
		    for s in ${S_PARAM[@]}; do
			for r in ${R_PARAM[@]}; do
			    ${RUN_METHOD} -tr ${TRAIN[@]} \
				-va ${VALID[@]} -o $ODIR -t $t \
				-# $MAXITER ${copt} -s $s -r $r
			done
		    done
		done
		;;
	    *)
		echo "Unknown kernel type: $t" >&2; exit 1
	esac
    done
done
