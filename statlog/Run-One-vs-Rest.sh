#!/bin/bash

shopt -s extglob
export LC_NUMERIC=C

PROG=${0##*/}
SVM_LIGHT_LEARN=svm_light/svm_learn
SVM_LIGHT_CLASS=svm_light/svm_classify

TRAIN=( `ls Data/sat6c.tra.svmlight.norm.train+([0-9])` )
VALID=( `ls Data/sat6c.tra.svmlight.norm.valid+([0-9])` )
MAXITER=1000000
C=1
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
    -c <c>           svm_learn regularization term
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

info="svmONE.VS.REST-maxit${MAXITER}-t$T"
svm_opt="-# ${MAXITER} -t $T"
if [ -z $C ]; then
    info=${info}-cDEFAULT;
else
    info=${info}-c${C};
    svm_opt="${svm_opt} -c $C"
fi
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
    [ -f $va.unk ] || {
    	awk '{ $1="0"; print $0; }' $va > $va.unk
    }
    [ -f $va.lbl ] || {
	./Extract-Labels.sh $va > $va.lbl
    }
    for class in `seq 1 6`; do
	ctr=${tr}.class${class};
	[ -f $ctr ] || {
	    awk -v c=$class '{
              if ($1 == c) { $1="+1"; } else { $1="-1"; }
              print $0
            }' $tr > $ctr
	}
	mdl=$ODIR/Model-${info}_`basename $ctr`.mdl
	out=$ODIR/Output-${info}_`basename $va`.class${class}.out
	echo "${SVM_LIGHT_LEARN} ${svm_opt} $ctr $mdl" &> ${mdl/.mdl/.log}
	${SVM_LIGHT_LEARN} ${svm_opt} $ctr $mdl &>> ${mdl/.mdl/.log}
	[ $? -ne 0 ] && {
	    echo "Training failed: ${mdl/.mdl/.log}"; exit 1;
	}
	echo "${SVM_LIGHT_CLASS} -f 1 $va.unk $mdl $out" &> ${out/.out/.log}
	${SVM_LIGHT_CLASS} -f 1 $va.unk $mdl $out &>> ${out/.out/.log}
        [ $? -ne 0 ] && {
            echo "Classif. failed: ${out/.out/.log}"; exit 1;
        }
    done
    va_multi=$ODIR/Output-${info}_`basename $va`.multi
    hyp=$ODIR/Output-${info}_`basename $va`.hyp
    paste $ODIR/Output-${info}_`basename $va`.class*.out > ${va_multi}
    # Get winner label
    ./Classify-One-vs-Rest.sh < $va_multi > $hyp
    err=$(./Compute-Error-Ratio.sh $va.lbl $hyp)
    serr=$(echo "$serr + $err" | bc -l)
    serr2=$(echo "$serr2 + $err * $err" | bc -l)
done
avg_err=$(echo "$serr / $NDATA" | bc -l)
std_err=$(echo "sqrt($serr2 / $NDATA - ${avg_err} * ${avg_err})" | bc -l)
int_err=$(echo "1.96 * $std_err / sqrt($NDATA)" | bc -l)
echo ${info} ${avg_err} ${int_err}
