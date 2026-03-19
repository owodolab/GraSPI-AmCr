#!/bin/bash

MAINDIR=$PWD

DESCS="$MAINDIR/descriptors"
KREC="$MAINDIR/calculateKrec"
NAMEDESC=`cut -d':' -f1 descriptors/descriptors.MorphParamSet19Fields_sv45_MorphoDesc.log | paste -sd ' ' - `

echo "name MUeG MUhG krG ETA dG $NAMEDESC "> AllDescriptors.txt

for i in $DESCS/*.log; do
    filename=$i
    filenameWOext=`echo $i | cut -d "." -f 2`

    echo "Processing: $filenameWOext"

    LOCALDESC=`cat $i | cut -d ':' -f2 | paste -sd' ' -`
    
    echo "localdesc: $LOCALDESC"
    
    target_key="n_M_eff"
    nMeff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "nMeff: $nMeff"
    target_key="e_A_eff"
    eAff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "eAff: $eAff"
    target_key="e_D_eff"
    eDeff=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "eDeff: $eDeff"
    target_key="Pb"
    Pb=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "Pb: $Pb"
    target_key="Pc"
    Pc=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "Pc: $Pc"
    target_key="Nb"
    Nb=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "Nb: $Nb"
    target_key="Nc"
    Nc=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "Nc: $Nc"
    target_key="n"
    N=$(grep "^$target_key:" $i | cut -d':' -f2- | xargs)
    echo "N: $N"
    
    
#   (Desc3a*1+DescPb+DescPc)/(Desc3a+DescNb+DescNc)
    denominator=$(echo "$nMeff + $Nb + $Nc" | bc -l)
    if (( $(echo "$denominator != 0" | bc -l) )); then
#        ETAdG=$(echo "scale=6; ($nMeff + $Pb + $Pc) / ($nMeff + $Nb + $Nc)" | bc)
        ETAdG=$(echo "scale=6; ($nMeff + $Pb + $Pc) / ($N)" | bc)
    else
        ETAdG=0;
    fi
    
    krecD=`echo descKrec-${filenameWOext}.txt`
    KrG=`cat $DESCS/$krecD`

    MUhG=`cat $DESCS/descMob-${filenameWOext}.txt | sed -n '/effMHole:/p' | sed -e "s/effMHole: //"  `
    MUeG=`cat $DESCS/descMob-${filenameWOext}.txt | sed -n '/effMEle:/p' | sed -e "s/effMEle: //" `
    
    
    
    echo "KrG: $KrG"
    echo "MUhG: $MUhG"
    echo "MUeG: $MUeG"
    echo "ETAdG: $ETAdG"
    echo "$filenameWOext ${MUeG} ${MUhG} ${KrG} ${ETAdG} $LOCALDESC " >> AllDescriptors.txt
done



