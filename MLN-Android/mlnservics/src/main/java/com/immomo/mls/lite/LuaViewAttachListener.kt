package com.immomo.mls.lite

import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.immomo.mls.`fun`.globals.LuaView

class LuaViewAttachListener : View.OnAttachStateChangeListener, LifecycleEventObserver {
    private var isFragment: Boolean = false
    private var isResume: Boolean = false


    override fun onViewAttachedToWindow(view: View) {
        if (view is LuaView) {
            if (isFragment) {
                if (isResume) {
                    view.onResume()
                }
            } else {
                view.onResume()
            }
        }
    }

    override fun onViewDetachedFromWindow(v: View) = Unit
    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        if (source is Fragment) {
            isFragment = true
        }
        if (event == Lifecycle.Event.ON_RESUME)
            isResume = true
    }
}