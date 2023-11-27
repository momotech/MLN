package com.immomo.mls.maker

import androidx.lifecycle.LifecycleOwner
import com.immomo.mls.InitData

interface LuaMakerFactory {
    fun newLuaMaker(lifecycleOwner: LifecycleOwner, data:InitData): ILuaMaker
}