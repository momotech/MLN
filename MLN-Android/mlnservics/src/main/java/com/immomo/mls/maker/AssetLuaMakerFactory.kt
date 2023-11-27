package com.immomo.mls.maker


import androidx.lifecycle.LifecycleOwner
import com.immomo.mls.InitData

class AssetLuaMakerFactory : LuaMakerFactory {
    override fun newLuaMaker(lifecycleOwner: LifecycleOwner, data: InitData): ILuaMaker =
        AssetLuaMaker(lifecycleOwner, data)
}