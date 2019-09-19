/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.immomo.mls.debug.DebugView;
import com.immomo.mls.log.DefaultPrinter;
import com.immomo.mls.log.IPrinter;
import com.immomo.mls.log.PrinterContainer;
import com.immomo.mls.utils.TouchMoveListener;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDialog;

/**
 * Created by XiongFangyu on 2018/9/6.
 */
public class MLSReloadButtonGenerator {
    private static final String TAG_EXCEPTION = "tag_exception";

    private MLSReloadButtonGenerator() {
    }

    public static View generateReloadButton(ViewGroup container, MLSInstance instance) {
        View ret = LayoutInflater.from(container.getContext()).inflate(R.layout.lv_default_reload_layout, container, false);
        final View reload = ret.findViewById(R.id.lv_reload_btn);
        final View main = ret.findViewById(R.id.lv_main_btn);
        final View log = ret.findViewById(R.id.lv_log_btn);
        final View debug = ret.findViewById(R.id.lv_debub_btn);
        final View _3dbtn = ret.findViewById(R.id.lv_3d_btn);
        final View version = ret.findViewById(R.id.lv_version);
        final View scan_qr = ret.findViewById(R.id.scan_qr);
        final View resetUsbPort = ret.findViewById(R.id.resetUsbPort);
//        final View hrbtn = ret.findViewById(R.id.lv_hr_btn);
        reload.setOnClickListener(instance.reloadClickListener);
        debug.setOnClickListener(debugListener(container));
        reload.setVisibility(View.GONE);
        log.setVisibility(View.GONE);
        debug.setVisibility(View.GONE);
        version.setVisibility(View.GONE);
        scan_qr.setVisibility(View.GONE);
        resetUsbPort.setVisibility(View.GONE);

        instance.onSTDPrinterCreated(createPrinterLayout(container));
        log.setOnClickListener(newLogListener(instance));

        _3dbtn.setVisibility(View.GONE);
        _3dbtn.setOnClickListener(new3DSwitchClickListener(instance));

        scan_qr.setOnClickListener(qrCodeClickListener(instance));
        resetUsbPort.setOnClickListener(resetUsbClickListener(container));

        version.setOnClickListener(newVersionClickListener(instance));
        main.setOnClickListener(new View.OnClickListener() {
            boolean visible = false;

            @Override
            public void onClick(View v) {
                visible = !visible;
                int visibility = visible ? View.VISIBLE : View.INVISIBLE;
                log.setVisibility(visibility);
                reload.setVisibility(visibility);
                debug.setVisibility(visibility);
                _3dbtn.setVisibility(visibility);
                version.setVisibility(visibility);
                scan_qr.setVisibility(visibility);
                resetUsbPort.setVisibility(visibility);
//                hrbtn.setVisibility(visibility);
            }
        });

        main.setOnTouchListener(new TouchMoveListener(ret, true));
        ret.setOnTouchListener(new TouchMoveListener());
        container.addView(ret);
        return ret;
    }

    private static View.OnClickListener newVersionClickListener(final MLSInstance instance) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String version = instance.getScriptVersion();
                Toast.makeText(instance.mContext, "当前加载的脚本版本号：" + version + "   SDK 版本号：" + Constants.SDK_VERSION, Toast.LENGTH_LONG).show();
            }
        };
    }

    public static void bringPrinterToFront(@NonNull IPrinter p) {
        View v = (View) ((View) p).getParent();
        v.bringToFront();
    }

    private static View.OnClickListener newLogListener(final PrinterContainer printerContainer) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                printerContainer.showPrinter(!printerContainer.isShowPrinter());
            }
        };
    }

    private static IPrinter createPrinterLayout(ViewGroup container) {
        LinearLayout linearLayout = new LinearLayout(container.getContext());
        linearLayout.setBackgroundColor(0x99444444);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        linearLayout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        linearLayout.setGravity(Gravity.CENTER_HORIZONTAL);
        TextView textView = new TextView(container.getContext());
        textView.setTextColor(Color.WHITE);
        textView.setGravity(Gravity.CENTER);
        int padding = (int) container.getContext().getResources().getDimension(R.dimen.text_padding);
        textView.setPadding(0, padding, 0, padding);
        textView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        textView.setText(container.getContext().getResources().getText(R.string.str_touch_move));
        final DefaultPrinter p = new DefaultPrinter(container.getContext());
        linearLayout.addView(p);
        linearLayout.addView(textView);
        container.addView(linearLayout);
        linearLayout.setVisibility(View.GONE);
        linearLayout.bringToFront();
        textView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                p.clear();
            }
        });
        textView.setOnTouchListener(new TouchMoveListener(linearLayout, true));
        return p;
    }

    private static View.OnClickListener debugListener(final ViewGroup container) {
        return new View.OnClickListener() {
            private DebugView debugView;

            @Override
            public void onClick(View v) {
                if (debugView == null) {
                    debugView = DebugView.getDebugView(container.getContext());
                    debugView.setOnTouchListener(new TouchMoveListener());
                    debugView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                    container.addView(debugView);
                } else {
                    if (debugView.getVisibility() == View.VISIBLE) {
                        debugView.setVisibility(View.GONE);
                    } else {
                        debugView.setVisibility(View.VISIBLE);
                    }
                }
            }
        };
    }

    private static View.OnClickListener new3DSwitchClickListener(final MLSInstance instance) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (instance.scalpelFrameLayout == null) {
                    return;
                }
                instance.scalpelFrameLayout.setLayerInteractionEnabled(!instance.scalpelFrameLayout.isLayerInteractionEnabled());
            }
        };
    }


    // 扫描二维码
    private static View.OnClickListener qrCodeClickListener(final MLSInstance instance) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (instance.scalpelFrameLayout == null) {
                    return;
                }
                if (MLSAdapterContainer.getQrCaptureAdapter() != null)
                    MLSAdapterContainer.getQrCaptureAdapter().startQrCapture(v.getContext());
            }
        };
    }

    // 扫描二维码
    private static View.OnClickListener resetUsbClickListener(final ViewGroup viewGroup) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showSetUsbPortDialog(viewGroup);
            }
        };
    }


    private static void showSetUsbPortDialog(final ViewGroup viewGroup) {

        Context context = viewGroup.getContext();

        View layout = LayoutInflater.from(context).inflate(R.layout.layout_reset_usb_port, null);

        final AppCompatDialog luaDialog = new AppCompatDialog(context);
        luaDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        luaDialog.setContentView(layout);
        luaDialog.setCancelable(false);

        final EditText editText = (layout.findViewById(R.id.port));
        editText.setText(HotReloadHelper.getUsbPort() + "");
        editText.setSelection(editText.getText().length());
        layout.findViewById(R.id.btn_cancel_port).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                luaDialog.dismiss();
            }
        });

        layout.findViewById(R.id.btn_confirm_port).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                luaDialog.dismiss();
                String ps = editText.getText().toString();
                if (TextUtils.isEmpty(ps))
                    return;
                try {
                    HotReloadHelper.setUseUSB(Integer.parseInt(ps));
                } catch (Throwable t) {
                    MLSAdapterContainer.getToastAdapter().toast("请输入数字");
                }
            }
        });

        luaDialog.show();
    }
}
