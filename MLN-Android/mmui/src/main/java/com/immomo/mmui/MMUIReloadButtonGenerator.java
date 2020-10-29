/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.immomo.mls.Constants;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.R;
import com.immomo.mls.debug.SettingDialog;
import com.immomo.mls.log.DefaultPrinter;
import com.immomo.mls.log.IPrinter;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.TouchMoveListener;
import com.immomo.mls.weight.AutoGravityLayout;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class MMUIReloadButtonGenerator implements View.OnClickListener {
    protected ViewGroup container;
    protected MMUIInstance instance;

    protected boolean visible;

    protected ViewGroup root;
    protected View center;
    protected View log;
    protected View reload;
    protected View _3d;
    protected View qr;
    protected View setting;
    protected View version;

    protected boolean isHotReloadPage;

    public MMUIReloadButtonGenerator(ViewGroup container, MMUIInstance instance) {
        this.container = container;
        this.instance = instance;
    }

    protected ViewGroup generateRoot() {
        AutoGravityLayout layout = new AutoGravityLayout(container.getContext());
        layout.setLayoutParams(generateRootLP(150, 150));
        return layout;
    }

    protected ViewGroup.LayoutParams generateRootLP(float w, float h) {
        return new ViewGroup.LayoutParams(DimenUtil.dpiToPx(w), DimenUtil.dpiToPx(h));
    }

    protected View centerView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_lua);
        iv.setLayoutParams(generateRootLP(50, 50));
        return iv;
    }

    protected View logView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_log);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    protected View reloadView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_reload);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    protected View _3DView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_icon_3d);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    protected View qrView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_qr);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    protected View settingView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_usbport);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    protected View versionView() {
        ImageView iv = new ImageView(container.getContext());
        iv.setImageResource(R.drawable.lv_version);
        iv.setLayoutParams(generateRootLP(35, 35));
        return iv;
    }

    public View generateReloadButton(boolean isHotReloadPage) {
        if (root != null)
            return root;
        this.isHotReloadPage = isHotReloadPage;
        root = generateRoot();

        center = centerView();
        if (root instanceof AutoGravityLayout) {
            ((AutoGravityLayout) root).setCenter(center);
        } else {
            root.addView(center);
        }
        if (center != null) {
            center.setOnTouchListener(new TouchMoveListener(root, true));
            center.setOnClickListener(this);
        }

        if (!isHotReloadPage)
        log = logView();
        if (log != null) {
            log.setOnClickListener(this);
            root.addView(log);

            instance.onSTDPrinterCreated(createPrinterLayout(container));
        }

        reload = reloadView();
        if (reload != null) {
            reload.setOnClickListener(instance.reloadClickListener);
            root.addView(reload);
        }

        _3d = _3DView();
        if (_3d != null) {
            _3d.setOnClickListener(this);
            root.addView(_3d);
        }

        if (MLSAdapterContainer.getQrCaptureAdapter() != null) {
            qr = qrView();
            if (qr != null) {
                qr.setOnClickListener(this);
                root.addView(qr);
            }
        }

        setting = settingView();
        if (setting != null) {
            setting.setOnClickListener(this);
            root.addView(setting);
        }

        version = versionView();
        if (version != null) {
            version.setOnClickListener(this);
            root.addView(version);
        }

        container.addView(root);

        setVisibility(View.GONE, log, reload, _3d, qr, setting, version);
        return root;
    }

    @Override
    public void onClick(View v) {
        if (v == center) {
            onCenterClick();
        } else if (v == log) {
            onLogClick();
        } else if (v == _3d) {
            on3DClick();
        } else if (v == qr) {
            onQrClick();
        } else if (v == setting) {
            onSettingClick();
        } else if (v == version) {
            onVersionClick();
        }
    }

    protected void onCenterClick() {
        visible = !visible;
        int visibility = visible ? View.VISIBLE : View.INVISIBLE;
        if (isHotReloadPage) {
            setVisibility(View.GONE, log, reload, version);
            setVisibility(visibility, _3d, qr, setting);
        } else {
            setVisibility(visibility, log, reload, _3d, qr, setting, version);
        }
    }

    protected void setVisibility(int c, View... views) {
        for (View v : views) {
            if (v != null)
                v.setVisibility(c);
        }
    }

    protected void onLogClick() {
        instance.showPrinter(!instance.isShowPrinter());
    }

    protected void on3DClick() {
        if (instance.scalpelFrameLayout == null) {
            return;
        }
        instance.scalpelFrameLayout.setLayerInteractionEnabled(!instance.scalpelFrameLayout.isLayerInteractionEnabled());
    }

    protected void onQrClick() {
        if (instance.scalpelFrameLayout == null) {
            return;
        }
        if (MLSAdapterContainer.getQrCaptureAdapter() != null)
            MLSAdapterContainer.getQrCaptureAdapter().startQrCapture(container.getContext());
    }

    protected void onVersionClick() {
        String version = instance.getScriptVersion();
        MLSAdapterContainer.getToastAdapter().toast("当前加载的脚本版本号：" + version + "   SDK 版本号：" + Constants.SDK_VERSION);
    }

    protected void onSettingClick() {
        Context context = container.getContext();

        SettingDialog d = new SettingDialog(context, true, isHotReloadPage);
        final boolean openDebug = MLSEngine.isOpenDebugger();
        d.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                if (openDebug != MLSEngine.isOpenDebugger() && !openDebug) {
                    instance.getGlobals().openDebug();
                }
            }
        });
        d.show();
    }

    protected static IPrinter createPrinterLayout(ViewGroup container) {
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
}