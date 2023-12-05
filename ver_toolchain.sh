CC_VER="$($1 -v 2>&1 | grep ' version ' | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
#LD_VER="$($2 -v | head -n1 | sed 's/(compatible with [^)]*)//' | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
echo "$CC_VER"
