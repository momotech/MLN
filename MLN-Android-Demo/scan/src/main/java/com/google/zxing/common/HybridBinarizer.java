/*
 * Copyright 2009 ZXing authors
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

package com.google.zxing.common;

import com.google.zxing.Binarizer;
import com.google.zxing.LuminanceSource;
import com.google.zxing.NotFoundException;

/**
 * This class implements a local thresholding algorithm, which while slower than the
 * GlobalHistogramBinarizer, is fairly efficient for what it does. It is designed for
 * high frequency images of barcodes with black data on white backgrounds. For this application,
 * it does a much better job than a global blackpoint with severe shadows and gradients.
 * However it tends to produce artifacts on lower frequency images and is therefore not
 * a good general purpose binarizer for uses outside ZXing.
 *
 * This class extends GlobalHistogramBinarizer, using the older histogram approach for 1D readers,
 * and the newer local approach for 2D readers. 1D decoding using a per-row histogram is already
 * inherently local, and only fails for horizontal gradients. We can revisit that problem later,
 * but for now it was not a win to use local blocks for 1D.
 *
 * This Binarizer is the default for the unit tests and the recommended class for library users.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public final class HybridBinarizer extends GlobalHistogramBinarizer {

    // This class uses 5x5 blocks to compute local luminance, where each block is 8x8 pixels.
    // So this is the smallest dimension in each axis we can accept.
    private static final int BLOCK_SIZE_POWER = 3;
    private static final int BLOCK_SIZE = 1 << BLOCK_SIZE_POWER; // ...0100...00
    private static final int BLOCK_SIZE_MASK = BLOCK_SIZE - 1;   // ...0011...11
    private static final int MINIMUM_DIMENSION = BLOCK_SIZE * 5;
    private static final int MIN_DYNAMIC_RANGE = 24;

    private BitMatrix matrix;

    public HybridBinarizer(LuminanceSource source) {
        super(source);
    }

    /**
     * Calculates the final BitMatrix once for all requests. This could be called once from the
     * constructor instead, but there are some advantages to doing it lazily, such as making
     * profiling easier, and not doing heavy lifting when callers don't expect it.
     */
    @Override
    public BitMatrix getBlackMatrix() throws NotFoundException {
        if (matrix != null) {
            return matrix;
        }
        LuminanceSource source = getLuminanceSource();
        int width = source.getWidth();
        int height = source.getHeight();
        if (width >= MINIMUM_DIMENSION && height >= MINIMUM_DIMENSION) {
            byte[] luminances = source.getMatrix();
            int subWidth = width >> BLOCK_SIZE_POWER;
            if ((width & BLOCK_SIZE_MASK) != 0) {
                subWidth++;
            }
            int subHeight = height >> BLOCK_SIZE_POWER;
            if ((height & BLOCK_SIZE_MASK) != 0) {
                subHeight++;
            }
            int[][] blackPoints = calculateBlackPoints(luminances, subWidth, subHeight, width, height);

            BitMatrix newMatrix = new BitMatrix(width, height);
            calculateThresholdForBlock(luminances, subWidth, subHeight, width, height, blackPoints, newMatrix);
            matrix = newMatrix;
        } else {
            // If the image is too small, fall back to the global histogram approach.
            matrix = super.getBlackMatrix();
        }
        return matrix;
    }

    @Override
    public Binarizer createBinarizer(LuminanceSource source) {
        return new HybridBinarizer(source);
    }

    /**
     * For each block in the image, calculate the average black point using a 5x5 grid
     * of the blocks around it. Also handles the corner cases (fractional blocks are computed based
     * on the last pixels in the row/column which are also used in the previous block).
     */
    private static void calculateThresholdForBlock(byte[] luminances,
                                                   int subWidth,
                                                   int subHeight,
                                                   int width,
                                                   int height,
                                                   int[][] blackPoints,
                                                   BitMatrix matrix) {
        for (int y = 0; y < subHeight; y++) {
            int yoffset = y << BLOCK_SIZE_POWER;
            int maxYOffset = height - BLOCK_SIZE;
            if (yoffset > maxYOffset) {
                yoffset = maxYOffset;
            }
            for (int x = 0; x < subWidth; x++) {
                int xoffset = x << BLOCK_SIZE_POWER;
                int maxXOffset = width - BLOCK_SIZE;
                if (xoffset > maxXOffset) {
                    xoffset = maxXOffset;
                }
                int left = cap(x, 2, subWidth - 3);
                int top = cap(y, 2, subHeight - 3);
                int sum = 0;
                for (int z = -2; z <= 2; z++) {
                    int[] blackRow = blackPoints[top + z];
                    sum += blackRow[left - 2] + blackRow[left - 1] + blackRow[left] + blackRow[left + 1] + blackRow[left + 2];
                }
                int average = sum / 25;
                thresholdBlock(luminances, xoffset, yoffset, average, width, matrix);
            }
        }
    }

    private static int cap(int value, int min, int max) {
        return value < min ? min : value > max ? max : value;
    }

    /**
     * Applies a single threshold to a block of pixels.
     */
    private static void thresholdBlock(byte[] luminances,
                                       int xoffset,
                                       int yoffset,
                                       int threshold,
                                       int stride,
                                       BitMatrix matrix) {
        for (int y = 0, offset = yoffset * stride + xoffset; y < BLOCK_SIZE; y++, offset += stride) {
            for (int x = 0; x < BLOCK_SIZE; x++) {
                // Comparison needs to be <= so that black == 0 pixels are black even if the threshold is 0.
                if ((luminances[offset + x] & 0xFF) <= threshold) {
                    matrix.set(xoffset + x, yoffset + y);
                }
            }
        }
    }

    /**
     * Calculates a single black point for each block of pixels and saves it away.
     * See the following thread for a discussion of this algorithm:
     *  http://groups.google.com/group/zxing/browse_thread/thread/d06efa2c35a7ddc0
     */
    private static int[][] calculateBlackPoints(byte[] luminances,
                                                int subWidth,
                                                int subHeight,
                                                int width,
                                                int height) {
        int[][] blackPoints = new int[subHeight][subWidth];
        for (int y = 0; y < subHeight; y++) {
            int yoffset = y << BLOCK_SIZE_POWER;
            int maxYOffset = height - BLOCK_SIZE;
            if (yoffset > maxYOffset) {
                yoffset = maxYOffset;
            }
            for (int x = 0; x < subWidth; x++) {
                int xoffset = x << BLOCK_SIZE_POWER;
                int maxXOffset = width - BLOCK_SIZE;
                if (xoffset > maxXOffset) {
                    xoffset = maxXOffset;
                }
                int sum = 0;
                int min = 0xFF;
                int max = 0;
                for (int yy = 0, offset = yoffset * width + xoffset; yy < BLOCK_SIZE; yy++, offset += width) {
                    for (int xx = 0; xx < BLOCK_SIZE; xx++) {
                        int pixel = luminances[offset + xx] & 0xFF;
                        sum += pixel;
                        // still looking for good contrast
                        if (pixel < min) {
                            min = pixel;
                        }
                        if (pixel > max) {
                            max = pixel;
                        }
                    }
                    // short-circuit min/max tests once dynamic range is met
                    if (max - min > MIN_DYNAMIC_RANGE) {
                        // finish the rest of the rows quickly
                        for (yy++, offset += width; yy < BLOCK_SIZE; yy++, offset += width) {
                            for (int xx = 0; xx < BLOCK_SIZE; xx++) {
                                sum += luminances[offset + xx] & 0xFF;
                            }
                        }
                    }
                }

                // The default estimate is the average of the values in the block.
                int average = sum >> (BLOCK_SIZE_POWER * 2);
                if (max - min <= MIN_DYNAMIC_RANGE) {
                    // If variation within the block is low, assume this is a block with only light or only
                    // dark pixels. In that case we do not want to use the average, as it would divide this
                    // low contrast area into black and white pixels, essentially creating data out of noise.
                    //
                    // The default assumption is that the block is light/background. Since no estimate for
                    // the level of dark pixels exists locally, use half the min for the block.
                    average = min / 2;

                    if (y > 0 && x > 0) {
                        // Correct the "white background" assumption for blocks that have neighbors by comparing
                        // the pixels in this block to the previously calculated black points. This is based on
                        // the fact that dark barcode symbology is always surrounded by some amount of light
                        // background for which reasonable black point estimates were made. The bp estimated at
                        // the boundaries is used for the interior.

                        // The (min < bp) is arbitrary but works better than other heuristics that were tried.
                        int averageNeighborBlackPoint =
                                (blackPoints[y - 1][x] + (2 * blackPoints[y][x - 1]) + blackPoints[y - 1][x - 1]) / 4;
                        if (min < averageNeighborBlackPoint) {
                            average = averageNeighborBlackPoint;
                        }
                    }
                }
                blackPoints[y][x] = average;
            }
        }
        return blackPoints;
    }

}
