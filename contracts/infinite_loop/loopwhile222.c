#include "vntlib.h"

KEY uint256 count = 0;

constructor While2(){
}

MUTABLE
uint256 test(uint256 x){
    PrintStr("while()", "while()");

    while (count <= 100)
        PrintUint256T("count:", count);
    count++;

    return count;
}
