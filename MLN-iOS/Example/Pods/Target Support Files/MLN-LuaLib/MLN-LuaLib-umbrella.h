#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "lapi.h"
#import "lcode.h"
#import "ldebug.h"
#import "ldo.h"
#import "lfunc.h"
#import "lgc.h"
#import "llex.h"
#import "llimits.h"
#import "lmem.h"
#import "lobject.h"
#import "lopcodes.h"
#import "lparser.h"
#import "lstate.h"
#import "lstring.h"
#import "ltable.h"
#import "ltm.h"
#import "lundump.h"
#import "lvm.h"
#import "lzio.h"
#import "mln_lauxlib.h"
#import "mln_lua.h"
#import "mln_luaconf.h"
#import "mln_lualib.h"

FOUNDATION_EXPORT double MLNVersionNumber;
FOUNDATION_EXPORT const unsigned char MLNVersionString[];

