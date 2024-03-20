//
// Created by momo783 on 2020/5/20.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#include "Vector.h"

ANIMATOR_NAMESPACE_BEGIN

static void CGColorGetRGBAComponents(CGColorRef color, CGFloat components[])
{
    if (color) {
        const CGFloat *colors = CGColorGetComponents(color);
        size_t count = CGColorGetNumberOfComponents(color);

        if (4 == count) {
            // RGB colorspace
            components[0] = colors[0];
            components[1] = colors[1];
            components[2] = colors[2];
            components[3] = colors[3];
        } else if (2 == count) {
            // Grey colorspace
            components[0] = components[1] = components[2] = colors[0];
            components[3] = colors[1];
        } else {
            // Use CI to convert
            CIColor *ciColor = [CIColor colorWithCGColor:color];
            components[0] = ciColor.red;
            components[1] = ciColor.green;
            components[2] = ciColor.blue;
            components[3] = ciColor.alpha;
        }
    } else {
        memset(components, 0, 4 * sizeof(components[0]));
    }
}

static CGColorRef CGColorRGBACreate(const CGFloat components[])
{
#if TARGET_OS_IPHONE
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(space, components);
    CGColorSpaceRelease(space);
    return color;
#else
    return CGColorCreateGenericRGB(components[0], components[1], components[2], components[3]);
#endif
}

Vector *Vector::new_cg_float(CGFloat f)
{
    Vector *v = new Vector(1);
    v->_values[0] = f;
    return v;
}

CGPoint Vector::cg_point () const
{
    Vector2r v = vector2r();
    return CGPointMake(v(0), v(1));
}

Vector *Vector::new_cg_point(const CGPoint &p)
{
    Vector *v = new Vector(2);
    v->_values[0] = p.x;
    v->_values[1] = p.y;
    return v;
}

CGSize Vector::cg_size () const
{
    Vector2r v = vector2r();
    return CGSizeMake(v(0), v(1));
}

Vector *Vector::new_cg_size(const CGSize &s)
{
    Vector *v = new Vector(2);
    v->_values[0] = s.width;
    v->_values[1] = s.height;
    return v;
}

CGRect Vector::cg_rect() const
{
    return _count < 4 ? CGRectZero : CGRectMake(_values[0], _values[1], _values[2], _values[3]);
}

Vector *Vector::new_cg_rect(const CGRect &r)
{
    Vector *v = new Vector(4);
    v->_values[0] = r.origin.x;
    v->_values[1] = r.origin.y;
    v->_values[2] = r.size.width;
    v->_values[3] = r.size.height;
    return v;
}

#if TARGET_OS_IPHONE

UIEdgeInsets Vector::ui_edge_insets() const
{
    return _count < 4 ? UIEdgeInsetsZero : UIEdgeInsetsMake(_values[0], _values[1], _values[2], _values[3]);
}

Vector *Vector::new_ui_edge_insets(const UIEdgeInsets &i)
{
    Vector *v = new Vector(4);
    v->_values[0] = i.top;
    v->_values[1] = i.left;
    v->_values[2] = i.bottom;
    v->_values[3] = i.right;
    return v;
}

#endif

CGAffineTransform Vector::cg_affine_transform() const
{
    if (_count < 6) {
        return CGAffineTransformIdentity;
    }

    ANIMATOR_ASSERT(size() >= 6);
    CGAffineTransform t;
    t.a = _values[0];
    t.b = _values[1];
    t.c = _values[2];
    t.d = _values[3];
    t.tx = _values[4];
    t.ty = _values[5];
    return t;
}

Vector *Vector::new_cg_affine_transform(const CGAffineTransform &t)
{
    Vector *v = new Vector(6);
    v->_values[0] = t.a;
    v->_values[1] = t.b;
    v->_values[2] = t.c;
    v->_values[3] = t.d;
    v->_values[4] = t.tx;
    v->_values[5] = t.ty;
    return v;
}

CGColorRef Vector::cg_color() const
{
    if (_count < 4) {
        return NULL;
    }
    return CGColorRGBACreate(_values);
}

Vector *Vector::new_cg_color(CGColorRef color)
{
    CGFloat rgba[4];
    CGColorGetRGBAComponents(color, rgba);
    return new_vector(4, rgba);
}

NSString * Vector::toString() const
{
    if (0 == _count)
        return @"()";

    if (1 == _count)
        return [NSString stringWithFormat:@"%f", _values[0]];

    if (2 == _count)
        return [NSString stringWithFormat:@"(%.3f, %.3f)", _values[0], _values[1]];

    NSMutableString *s = [NSMutableString stringWithCapacity:10];

    for (NSUInteger idx = 0; idx < _count; idx++) {
        if (0 == idx) {
            [s appendFormat:@"[%.3f", _values[idx]];
        } else if (idx == _count - 1) {
            [s appendFormat:@", %.3f]", _values[idx]];
        } else {
            [s appendFormat:@", %.3f", _values[idx]];
        }
    }

    return s;

}


ANIMATOR_NAMESPACE_END