//
//  MLNThread.h
//  MLNDevTool
//
//  Created by MOMO on 2020/1/6.
//

#import "lstate.h"

lua_State *mln_create_vm_in_subthread(void);
void mln_set_vm_bundle_path(lua_State *PL, lua_State *L);
void mln_release_vm_in_subthread(lua_State *L);
