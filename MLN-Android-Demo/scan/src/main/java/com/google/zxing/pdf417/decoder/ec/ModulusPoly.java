/*
 * Copyright 2012 ZXing authors
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

package com.google.zxing.pdf417.decoder.ec;

/**
 * @author Sean Owen
 * @see com.google.zxing.common.reedsolomon.GenericGFPoly
 */
final class ModulusPoly {

    private final ModulusGF field;
    private final int[] coefficients;

    ModulusPoly(ModulusGF field, int[] coefficients) {
        if (coefficients.length == 0) {
            throw new IllegalArgumentException();
        }
        this.field = field;
        int coefficientsLength = coefficients.length;
        if (coefficientsLength > 1 && coefficients[0] == 0) {
            // Leading term must be non-zero for anything except the constant polynomial "0"
            int firstNonZero = 1;
            while (firstNonZero < coefficientsLength && coefficients[firstNonZero] == 0) {
                firstNonZero++;
            }
            if (firstNonZero == coefficientsLength) {
                this.coefficients = new int[]{0};
            } else {
                this.coefficients = new int[coefficientsLength - firstNonZero];
                System.arraycopy(coefficients,
                        firstNonZero,
                        this.coefficients,
                        0,
                        this.coefficients.length);
            }
        } else {
            this.coefficients = coefficients;
        }
    }

    int[] getCoefficients() {
        return coefficients;
    }

    /**
     * @return degree of this polynomial
     */
    int getDegree() {
        return coefficients.length - 1;
    }

    /**
     * @return true iff this polynomial is the monomial "0"
     */
    boolean isZero() {
        return coefficients[0] == 0;
    }

    /**
     * @return coefficient of x^degree term in this polynomial
     */
    int getCoefficient(int degree) {
        return coefficients[coefficients.length - 1 - degree];
    }

    /**
     * @return evaluation of this polynomial at a given point
     */
    int evaluateAt(int a) {
        if (a == 0) {
            // Just return the x^0 coefficient
            return getCoefficient(0);
        }
        int size = coefficients.length;
        if (a == 1) {
            // Just the sum of the coefficients
            int result = 0;
            for (int coefficient : coefficients) {
                result = field.add(result, coefficient);
            }
            return result;
        }
        int result = coefficients[0];
        for (int i = 1; i < size; i++) {
            result = field.add(field.multiply(a, result), coefficients[i]);
        }
        return result;
    }

    ModulusPoly add(ModulusPoly other) {
        if (!field.equals(other.field)) {
            throw new IllegalArgumentException("ModulusPolys do not have same ModulusGF field");
        }
        if (isZero()) {
            return other;
        }
        if (other.isZero()) {
            return this;
        }

        int[] smallerCoefficients = this.coefficients;
        int[] largerCoefficients = other.coefficients;
        if (smallerCoefficients.length > largerCoefficients.length) {
            int[] temp = smallerCoefficients;
            smallerCoefficients = largerCoefficients;
            largerCoefficients = temp;
        }
        int[] sumDiff = new int[largerCoefficients.length];
        int lengthDiff = largerCoefficients.length - smallerCoefficients.length;
        // Copy high-order terms only found in higher-degree polynomial's coefficients
        System.arraycopy(largerCoefficients, 0, sumDiff, 0, lengthDiff);

        for (int i = lengthDiff; i < largerCoefficients.length; i++) {
            sumDiff[i] = field.add(smallerCoefficients[i - lengthDiff], largerCoefficients[i]);
        }

        return new ModulusPoly(field, sumDiff);
    }

    ModulusPoly subtract(ModulusPoly other) {
        if (!field.equals(other.field)) {
            throw new IllegalArgumentException("ModulusPolys do not have same ModulusGF field");
        }
        if (other.isZero()) {
            return this;
        }
        return add(other.negative());
    }

    ModulusPoly multiply(ModulusPoly other) {
        if (!field.equals(other.field)) {
            throw new IllegalArgumentException("ModulusPolys do not have same ModulusGF field");
        }
        if (isZero() || other.isZero()) {
            return field.getZero();
        }
        int[] aCoefficients = this.coefficients;
        int aLength = aCoefficients.length;
        int[] bCoefficients = other.coefficients;
        int bLength = bCoefficients.length;
        int[] product = new int[aLength + bLength - 1];
        for (int i = 0; i < aLength; i++) {
            int aCoeff = aCoefficients[i];
            for (int j = 0; j < bLength; j++) {
                product[i + j] = field.add(product[i + j], field.multiply(aCoeff, bCoefficients[j]));
            }
        }
        return new ModulusPoly(field, product);
    }

    ModulusPoly negative() {
        int size = coefficients.length;
        int[] negativeCoefficients = new int[size];
        for (int i = 0; i < size; i++) {
            negativeCoefficients[i] = field.subtract(0, coefficients[i]);
        }
        return new ModulusPoly(field, negativeCoefficients);
    }

    ModulusPoly multiply(int scalar) {
        if (scalar == 0) {
            return field.getZero();
        }
        if (scalar == 1) {
            return this;
        }
        int size = coefficients.length;
        int[] product = new int[size];
        for (int i = 0; i < size; i++) {
            product[i] = field.multiply(coefficients[i], scalar);
        }
        return new ModulusPoly(field, product);
    }

    ModulusPoly multiplyByMonomial(int degree, int coefficient) {
        if (degree < 0) {
            throw new IllegalArgumentException();
        }
        if (coefficient == 0) {
            return field.getZero();
        }
        int size = coefficients.length;
        int[] product = new int[size + degree];
        for (int i = 0; i < size; i++) {
            product[i] = field.multiply(coefficients[i], coefficient);
        }
        return new ModulusPoly(field, product);
    }

    ModulusPoly[] divide(ModulusPoly other) {
        if (!field.equals(other.field)) {
            throw new IllegalArgumentException("ModulusPolys do not have same ModulusGF field");
        }
        if (other.isZero()) {
            throw new IllegalArgumentException("Divide by 0");
        }

        ModulusPoly quotient = field.getZero();
        ModulusPoly remainder = this;

        int denominatorLeadingTerm = other.getCoefficient(other.getDegree());
        int inverseDenominatorLeadingTerm = field.inverse(denominatorLeadingTerm);

        while (remainder.getDegree() >= other.getDegree() && !remainder.isZero()) {
            int degreeDifference = remainder.getDegree() - other.getDegree();
            int scale = field.multiply(remainder.getCoefficient(remainder.getDegree()), inverseDenominatorLeadingTerm);
            ModulusPoly term = other.multiplyByMonomial(degreeDifference, scale);
            ModulusPoly iterationQuotient = field.buildMonomial(degreeDifference, scale);
            quotient = quotient.add(iterationQuotient);
            remainder = remainder.subtract(term);
        }

        return new ModulusPoly[]{quotient, remainder};
    }

    @Override
    public String toString() {
        StringBuilder result = new StringBuilder(8 * getDegree());
        for (int degree = getDegree(); degree >= 0; degree--) {
            int coefficient = getCoefficient(degree);
            if (coefficient != 0) {
                if (coefficient < 0) {
                    result.append(" - ");
                    coefficient = -coefficient;
                } else {
                    if (result.length() > 0) {
                        result.append(" + ");
                    }
                }
                if (degree == 0 || coefficient != 1) {
                    result.append(coefficient);
                }
                if (degree != 0) {
                    if (degree == 1) {
                        result.append('x');
                    } else {
                        result.append("x^");
                        result.append(degree);
                    }
                }
            }
        }
        return result.toString();
    }

}
