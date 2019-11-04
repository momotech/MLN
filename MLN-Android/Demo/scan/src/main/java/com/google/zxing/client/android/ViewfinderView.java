/*
 * Copyright (C) 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.zxing.client.android;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Shader;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;

import com.google.zxing.R;
import com.google.zxing.ResultPoint;
import com.google.zxing.client.android.camera.CameraManager;

import java.util.ArrayList;
import java.util.List;

/**
 * This view is overlaid on top of the camera preview. It adds the viewfinder rectangle and partial
 * transparency outside it, as well as the laser scanner animation and result points.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public final class ViewfinderView extends View {

    private static final long ANIMATION_DELAY = 30L;
    private static final int CURRENT_POINT_OPACITY = 0xA0;
    private static final int MAX_RESULT_POINTS = 20;
    private static final int POINT_SIZE = 6;

    private float distance = 0.01f;
    private float corPadding = 3f;//四个角的panding dp
    private float corLineSize = 16;//四个角线的长度 dp
    private float corLineWidth = 2f;//四个角线的宽度 dp
    private float tailPadding = 2f;//公共padding dp
    private float textSize = 44;//提示文字大小
    private float textWidth;

    private float[] corners;

    private CameraManager cameraManager;
    private final Paint paint;
    private final TextPaint textpaint;
    private Bitmap resultBitmap;
    private final int maskColor;
    private final int resultColor;
    private final int laserColor;
    private final int tailColor;
    private final int textColor;
    private final int resultPointColor;
    private String textContent;
    private List<ResultPoint> possibleResultPoints;
    private List<ResultPoint> lastPossibleResultPoints;
    private final Matrix gradientMatrix;

    private LinearGradient lineGradient, upTailGradient, downTailGradient;
    private int[] gradientColors;
    private float proccess;//横线位置
    private boolean upDown;//横线方向 false为上 true为下

    private boolean alwasyDown = false;//动画，始终往下扫描，false为上下循环扫描


    // This constructor is used when the class is built from an XML resource.
    public ViewfinderView(Context context, AttributeSet attrs) {
        super(context, attrs);
        //尺寸转化
        corPadding=Dp2Px(context,corPadding);
        corLineSize=Dp2Px(context,corLineSize);
        corLineWidth=Dp2Px(context,corLineWidth);

        // Initialize these once for performance rather than calling them every time in onDraw().
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        textpaint = new TextPaint(Paint.ANTI_ALIAS_FLAG);

        paint.setStrokeCap(Paint.Cap.ROUND);
        paint.setStrokeJoin(Paint.Join.ROUND);
        paint.setStrokeWidth(corLineWidth);

        Resources resources = getResources();
        maskColor = resources.getColor(R.color.viewfinder_mask);
        resultColor = resources.getColor(R.color.result_view);
        laserColor = resources.getColor(R.color.viewfinder_laser);
        tailColor = resources.getColor(R.color.viewfinder_tail);
        textColor = resources.getColor(R.color.status_text);
        textContent = (String) resources.getText(R.string.msg_default_status);
        resultPointColor = resources.getColor(R.color.possible_result_points);

        gradientColors = new int[]{Color.TRANSPARENT, laserColor, laserColor, laserColor, laserColor, Color.TRANSPARENT};

        textpaint.setColor(textColor);
        textpaint.setTextSize(textSize);
        Rect textBounds = new Rect();
        textpaint.getTextBounds(textContent, 0, textContent.length(), textBounds);
        textWidth = textBounds.width(); //文字宽度

        gradientMatrix = new Matrix();

        proccess = 0.0f;//初始化
        upDown = true;

        possibleResultPoints = new ArrayList<>(5);
        lastPossibleResultPoints = null;
    }

    public void setCameraManager(CameraManager cameraManager) {
        this.cameraManager = cameraManager;
    }

    @SuppressLint("DrawAllocation")
    @Override
    public void onDraw(Canvas canvas) {
        if (cameraManager == null) {
            return; // not ready yet, early draw before done configuring
        }
        Rect frame = cameraManager.getFramingRect();
        Rect previewFrame = cameraManager.getFramingRectInPreview();

        if (frame == null || previewFrame == null) {
            return;
        }
        int width = canvas.getWidth();
        int height = canvas.getHeight();

        // Draw the exterior (i.e. outside the framing rect) darkened
        paint.setColor(resultBitmap != null ? resultColor : maskColor);
        paint.setShader(null);
        canvas.drawRect(0, 0, width, frame.top, paint);
        canvas.drawRect(0, frame.top, frame.left, frame.bottom + 1, paint);
        canvas.drawRect(frame.right + 1, frame.top, width, frame.bottom + 1, paint);
        canvas.drawRect(0, frame.bottom + 1, width, height, paint);


        //corner四周的扫描直角 start
        paint.setColor(laserColor);

        if (corners == null) {
            corners = new float[]{//四个角，线的坐标
                    frame.left - corPadding, frame.top - corPadding, frame.left - corPadding + corLineSize, frame.top - corPadding,
                    frame.left - corPadding, frame.top - corPadding, frame.left - corPadding, frame.top - corPadding + corLineSize,
                    frame.right + corPadding, frame.top - corPadding, frame.right + corPadding - corLineSize, frame.top - corPadding,
                    frame.right + corPadding, frame.top - corPadding, frame.right + corPadding, frame.top - corPadding + corLineSize,
                    frame.left - corPadding, frame.bottom + corPadding, frame.left - corPadding + corLineSize, frame.bottom + corPadding,
                    frame.left - corPadding, frame.bottom + corPadding, frame.left - corPadding, frame.bottom + corPadding - corLineSize,
                    frame.right + corPadding, frame.bottom + corPadding, frame.right + corPadding - corLineSize, frame.bottom + corPadding,
                    frame.right + corPadding, frame.bottom + corPadding, frame.right + corPadding, frame.bottom + corPadding - corLineSize,

            };
        }

        canvas.drawLines(corners, paint);
        //corner end


        if (resultBitmap != null) {
            // Draw the opaque result bitmap over the scanning rectangle
            paint.setAlpha(CURRENT_POINT_OPACITY);
            canvas.drawBitmap(resultBitmap, null, frame, paint);
        } else {

            // Draw a red "laser scanner" line through the middle to show decoding is active
            int middle = (int) (frame.height() * proccess) + frame.top;

            proccess = getProccess(proccess, alwasyDown);

            //tail扫描尾巴 start
            if (upDown) {//下滑
                if (upTailGradient == null) {
                    upTailGradient = new LinearGradient(
                            frame.left, frame.top, frame.left, frame.top + frame.height() / 4,
                            Color.TRANSPARENT, tailColor,
                            Shader.TileMode.CLAMP
                    );
                }

                int tailDy = (middle - frame.height() / 4);//tailDy小于frame.top，表示尾巴显示不全
                int tailStart = (tailDy > frame.top) ? tailDy : frame.top;//尾巴开始位置
                gradientMatrix.setTranslate(0, tailStart - frame.top);//渐变竖直移动
                upTailGradient.setLocalMatrix(gradientMatrix);
                paint.setShader(upTailGradient);
                canvas.drawRect(frame.left + tailPadding, tailStart, frame.right - tailPadding, middle - tailPadding, paint);
            } else {//上滑
                if (downTailGradient == null) {
                    downTailGradient = new LinearGradient(
                            frame.left, frame.bottom - frame.height() / 4, frame.left, frame.bottom,
                            tailColor, Color.TRANSPARENT,
                            Shader.TileMode.CLAMP
                    );
                }

                int tailDy = (middle + frame.height() / 4);
                int tailEnd = (tailDy < frame.bottom) ? tailDy : frame.bottom;//尾巴结束位置
                gradientMatrix.setTranslate(0, tailEnd - frame.bottom);
                downTailGradient.setLocalMatrix(gradientMatrix);
                paint.setShader(downTailGradient);
                canvas.drawRect(frame.left + tailPadding, middle + tailPadding, frame.right - tailPadding, tailEnd, paint);
            }

            //tail扫描尾巴 end

            //line扫描线 start
            if (lineGradient == null) {
                lineGradient = new LinearGradient(
                        frame.left + 2, 0, frame.right - 1, 0,
                        gradientColors, null,
                        Shader.TileMode.CLAMP
                );
            }
            paint.setShader(lineGradient);

            canvas.drawRect(frame.left + 2, middle - 2, frame.right - 2, middle + 2, paint);

            //line扫描线 end

            //扫描黄点 start
            float scaleX = frame.width() / (float) previewFrame.width();
            float scaleY = frame.height() / (float) previewFrame.height();

            List<ResultPoint> currentPossible = possibleResultPoints;
            List<ResultPoint> currentLast = lastPossibleResultPoints;
            if (currentPossible.isEmpty()) {
                lastPossibleResultPoints = null;
            } else {
                possibleResultPoints = new ArrayList<>(5);
                lastPossibleResultPoints = currentPossible;
                paint.setAlpha(CURRENT_POINT_OPACITY);
                paint.setColor(resultPointColor);
                paint.setShader(null);
                synchronized (currentPossible) {
                    for (ResultPoint point : currentPossible) {
                        canvas.drawCircle(frame.left + (int) (point.getX() * scaleX),
                                frame.top + (int) (point.getY() * scaleY),
                                POINT_SIZE, paint);
                    }
                }
            }
            if (currentLast != null) {
                paint.setAlpha(CURRENT_POINT_OPACITY / 2);
                paint.setColor(resultPointColor);
                paint.setShader(null);
                synchronized (currentLast) {
                    for (ResultPoint point : currentLast) {
                        canvas.drawCircle(frame.left + (int) (point.getX() * scaleX),
                                frame.top + (int) (point.getY() * scaleY),
                                POINT_SIZE / 2.0f, paint);
                    }
                }
            }
            //扫描黄点 end

            //提示文字 start
            int pandding = (int) ((width - textWidth) / 2);//文字距 frame left距离
            int panddingBottom = (int) (corPadding + textSize + 28);//文字距 frame底部间距

            canvas.drawText(textContent, pandding, frame.bottom + panddingBottom,
                    textpaint);
            //提示文字 end

            // Request another update at the animation interval, but only repaint the laser line,
            // not the entire viewfinder mask.
            postInvalidateDelayed(ANIMATION_DELAY,
                    frame.left - POINT_SIZE,
                    frame.top - POINT_SIZE,
                    frame.right + POINT_SIZE,
                    frame.bottom + POINT_SIZE);
        }
    }

    /**
     * 获取当前位置
     *
     * @param proccess
     * @param isAlwasyDown 是否只向下扫描
     * @return
     */
    private float getProccess(float proccess, boolean isAlwasyDown) {
        if (isAlwasyDown) {
            proccess += distance;

            if (proccess > 1) {
                proccess = 0f;
            }
        } else {
            proccess = getProccess(proccess);
        }
        return proccess;
    }

    /**
     * 获取当前位置
     * <p>
     * ps；上下循环扫描
     * proccess 当前所在位置与fame高度的比例
     *
     * @return
     */
    private float getProccess(float proccess) {
        if (upDown) {//false为上 true为下
            proccess += distance;
        } else {
            proccess -= distance;
        }

        if (proccess > 1) {
            upDown = false;
            proccess = 1f;
        } else if (proccess < 0) {
            upDown = true;
            proccess = 0f;
        }
        return proccess;
    }

    public void drawViewfinder() {
        Bitmap resultBitmap = this.resultBitmap;
        this.resultBitmap = null;
        if (resultBitmap != null) {
            resultBitmap.recycle();
        }
        invalidate();
    }

    public static int Dp2Px(Context context, float dpi) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpi, context.getResources().getDisplayMetrics());
    }

    /**
     * Draw a bitmap with the result points highlighted instead of the live scanning display.
     *
     * @param barcode An image of the decoded barcode.
     */
    public void drawResultBitmap(Bitmap barcode) {
        resultBitmap = barcode;
        invalidate();
    }

    public void addPossibleResultPoint(ResultPoint point) {
        List<ResultPoint> points = possibleResultPoints;
        synchronized (points) {
            points.add(point);
            int size = points.size();
            if (size > MAX_RESULT_POINTS) {
                // trim it
                points.subList(0, size - MAX_RESULT_POINTS / 2).clear();
            }
        }
    }

    /**
     * 更新提示文字
     *
     * @param content
     */
    public void setNoticeText(String content) {
        textContent = content;
        invalidate();
    }
}
