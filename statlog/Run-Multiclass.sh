#!/bin/bash

shopt -s extglob
export LC_NUMERIC=C

PROG=${0##*/}
SVM_LIGHT_LEARN=svm_multiclass/svm_multiclass_learn
SVM_LIGHT_CLASS=svm_multiclass/svm_multiclass_classify

TRAIN=( `ls Data/sat6c.tra.norm.svmlight.train+([0-9])` )
VALID=( `ls Data/sat6c.tra.norm.svmlight.valid+([0-9])` )
MAXITER=1000000
C=0.01
T=0
D=1
G=1
S=1
R=1
ODIR=

function usage {
cat <<-EOF >&2
Usage: $PROG -o <dir> [-tr <tr-file>... -va <va-file>...] [OPTIONS]
Options:
    -h               show this help
    -tr <train> ...  training files
    -va <valid> ...  validation files
    -o <out-dir>     output directory
    -c <c>           svm_learn regularization term. Default: $C
    -t <kernel>      svm_learn kernel type. Default: $T
    -d <d>           svm_learn d parameter. Default: $D
    -g <gamma>       svm_learn g parameter. Default: $G
    -s <s>           svm_learn s parameter. Default: $S
    -r <r>           svm_learn r parameter. Default: $R
    -# <iters>       svm_learn iterations. Default: $MAXITER
EOF
}

while [ "${1:0:1}" = "-" ]; do
    case "$1" in
	"-h")
	    usage;
	    exit 0;
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
	"-#")
	    MAXITER="$2"; shift 2;
	    ;;
	"-c")
	    C="$2"; shift 2;
	    ;;
	"-t")
	    T="$2"; shift 2;
	    ;;
	"-d")
	    D="$2"; shift 2;
	    ;;
	"-g")
	    G="$2"; shift 2;
	    ;;
	"-s")
	    S="$2"; shift 2;
	    ;;
	"-r")
	    R="$2"; shift 2;
	    ;;
	*)
            echo "Unknown option: $1"; exit 1;
    esac
done

info="svmMULTI-maxit${MAXITER}-t$T-c${C}"
svm_opt="-# ${MAXITER} -t $T -c $C"
case "$T" in
    0)
	;;
    1)
	info=${info}-d${D}-s${S}-r${R}
	svm_opt="${svm_opt} -d $D -s $S -r $R"
	;;
    2)
	info=${info}-g${G}
	svm_opt="${svm_opt} -g $G"
	;;
    3)
	info=${info}-s${S}-r${R}
	svm_opt="${svm_opt} -s $S -r $R"
	;;
    *)
	echo "Unknown kernel type: $T"; exit 1;
esac
[ -z $ODIR ] && { echo "Output dir expected"; exit 1; }
[ ${#TRAIN[@]} -ne ${#VALID[@]} ] && {
    echo "Number of training and valid sets do not match\
 (${#TRAIN[@]} vs. ${#VALID[@]})"; exit 1;
}
[ ${#TRAIN[@]} -eq 0 ] && { echo "At least one dataset expected."; exit 1; }

mkdir -p $ODIR
serr=0.0
serr2=0.0
NDATA=${#TRAIN[@]};
for i in `seq 0 $[$NDATA - 1]`; do
    tr=${TRAIN[$i]}; va=${VALID[$i]};
    mdl=$ODIR/Model-${info}_`basename $tr`.mdl
    out=$ODIR/Output-${info}_`basename $va`.out
    echo "${SVM_LIGHT_LEARN} ${svm_opt} $tr $mdl" &> ${mdl/.mdl/.log}
    ${SVM_LIGHT_LEARN} ${svm_opt} $tr $mdl &>> ${mdl/.mdl/.log}
    [ $? -ne 0 ] && { echo "Training failed: ${mdl/.mdl/.log}"; exit 1; }
    echo "${SVM_LIGHT_CLASS} $va $mdl $out" &> ${out/.out/.log}
    ${SVM_LIGHT_CLASS} $va $mdl $out &>> ${out/.out/.log}
    [ $? -ne 0 ] && { echo "Classif. failed: ${out/.out/.log}"; exit 1; }
    set -e
    err=$(grep "Average loss on test set:" ${out/.out/.log} \
        | awk '{print $NF}')
    serr=$(echo "$serr + $err" | bc -l)
    serr2=$(echo "$serr2 + $err * $err" | bc -l)
    set +e
done
set -e
avg_err=$(echo "$serr / $NDATA" | bc -l)
std_err=$(echo "sqrt($serr2 / $NDATA - ${avg_err} * ${avg_err})" | bc -l)
echo $info ${avg_err} ${std_err}
set +e