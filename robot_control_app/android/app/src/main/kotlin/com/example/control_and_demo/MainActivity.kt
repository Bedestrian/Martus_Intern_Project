package com.example.control_and_demo

import android.hardware.input.InputManager
import android.os.Handler
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity
import org.flame_engine.gamepads_android.GamepadsCompatibleActivity

class MainActivity: FlutterActivity(), GamepadsCompatibleActivity {
    private var keyListener: ((KeyEvent)->Boolean)? = null
    private var motionListener: ((MotionEvent)->Boolean)? = null

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        return keyListener?.invoke(event) ?: super.dispatchKeyEvent(event)
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        return motionListener?.invoke(event) ?: super.dispatchGenericMotionEvent(event)
    }

    override fun registerKeyEventHandler(handler: (KeyEvent)->Boolean) {
        keyListener = handler
    }
    override fun registerMotionEventHandler(handler: (MotionEvent)->Boolean) {
        motionListener = handler
    }
    override fun registerInputDeviceListener(listener: InputManager.InputDeviceListener, handler: Handler?) {
        val mgr = getSystemService(INPUT_SERVICE) as InputManager
        mgr.registerInputDeviceListener(listener, null)
    }
}