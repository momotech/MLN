//
//  MLNUIExtScope.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/9.
//

#import "MLNUIExtScope.h"

void mln_executeCleanupBlock (__strong mln_cleanupBlock_t *block) {
    (*block)();
}
