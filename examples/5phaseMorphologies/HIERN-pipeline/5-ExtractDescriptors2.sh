#!/bin/bash

MAINDIR=$PWD

DESCS="$MAINDIR/descriptors"
KREC="$MAINDIR/calculateKrec"
VIS="$MAINDIR/visualizeData"
MOB="$MAINDIR/calculateMobility"
NAMEDESC=`cut -d':' -f1 descriptors/descriptors.MorphFields_sv99_MorphoDesc.log | paste -sd ' ' - `

#echo "name MUeG MUhG krG ETA_dG $NAMEDESC "> $VIS/AllDescriptors.txt

for i in $DESCS/*$1.log; do
    filename=$i
    #filenameWOext=`echo $i | cut -d "." -f 2`
    filenameWOext=`echo $i | cut -d "." -f 3`
    #filenameWOext="${i%.*}"
    echo "Processing: $filenameWOext"

    LOCALDESC=`cat $i | cut -d ':' -f2 | paste -sd' ' -`
    
    target_key="n_M_eff"
    nMeff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="e_A_eff"
    eAff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="e_D_eff"
    eDeff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="Pb"
    Pb=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="Pc"
    Pc=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="Nb"
    Nb=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="Nc"
    Nc=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    target_key="n"
    N=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    
    
#   (Desc3a*1+DescPb+DescPc)/(Desc3a+DescNb+DescNc)
    denominator=$(echo "$nMeff + $Nb + $Nc" | bc -l)
    if (( $(echo "$denominator != 0" | bc -l) )); then
#        ETAdG=$(echo "scale=6; ($nMeff + $Pb + $Pc) / ($nMeff + $Nb + $Nc)" | bc)
       ETAdG=$(echo "scale=6; ($nMeff + $Pb + $Pc) / ($N)" | bc)
    else
        ETAdG=0;
    fi
    
    krecD=`echo descKrec-${filenameWOext}.txt`
    KrG=`cat $KREC/$krecD`

    MUhG=`cat $MOB/descMob-${filenameWOext}.txt | sed -n '/effMHole:/p' | sed -e "s/effMHole: //"  `
    MUeG=`cat $MOB/descMob-${filenameWOext}.txt | sed -n '/effMEle:/p' | sed -e "s/effMEle: //" `
    
    
    echo "N: $N"
    echo "KrG: $KrG"
    echo "MUhG: $MUhG"
    echo "MUeG: $MUeG"
    echo "ETAdG: $ETAdG"
    #echo "$filenameWOext ${MUeG} ${MUhG} ${KrG} ${ETAdG} $LOCALDESC " >> $VIS/AllDescriptors.txt
    echo "$filenameWOext ${MUeG} ${MUhG} ${KrG} ${ETAdG} $LOCALDESC " >> $2

done



