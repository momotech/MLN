package com.immomo.mls;

import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;

import static org.junit.Assert.assertEquals;

public class LinearLayoutSortTest {
    private FakeLayout layout;

    @Before
    public void beforeTest() {
        layout = new FakeLayout();
        layout.addView(new FakeView(0))     //0 4
                .addView(new FakeView(1))   //1 3
                .addView(new FakeView(2))   //2 2
                .addView(new FakeView(4))   //3 0
                .addView(new FakeView(3))   //4 2
                .addView(new FakeView(4))   //5 1
                ;
    }

    @Test
    public void addTest() {
        FakeView child = new FakeView(3);
        layout.addView(child);
        assertEquals(child, layout.getChildAt(2));
        child = new FakeView(1);
        layout.addView(child);
        assertEquals(child, layout.getChildAt(5));
        child = new FakeView(5);
        layout.addView(child);
        child = new FakeView(6);
        layout.addView(child);
        child = new FakeView(5);
        layout.addView(child);
        child = new FakeView(6);
        layout.addView(child);

        Log.i(layout);
    }

    @Test
    public void changeTest() {
        FakeView child = layout.getChildAt(2);
        child.changePriority(4);
        Log.i(layout);
        assertEquals(child, layout.getChildAt(1));
    }

    @Test
    public void removeTest() {
        FakeView child = layout.getChildAt(2);
        Log.i(layout);
        layout.removeView(child);
        assertEquals(5, layout.childCount);
        Log.i(layout);
    }

    static final class FakeLayout {
        private static final float DEFAULT_LOAD_FACTOR = 0.75f;

        FakeView[] children = new FakeView[10];
        int childCount = 0;

        public FakeLayout addView(FakeView v) {
            v.parent = this;
            v.index = childCount;
            addViewToArray(v);
            return this;
        }

        public void removeView(FakeView v) {
            removeViewFromArray(v);
        }

        public FakeView getChildAt(int index) {
            return children[index];
        }

        public void onViewPriorityChanged(FakeView child, int oldPriority, int newPriority) {
            int oldIndex = -1;
            for (int i = 0; i < childCount; i ++) {
                if (children[i] == child) {
                    oldIndex = i;
                    break;
                }
            }
            if (oldIndex == -1) {
                throw new IllegalStateException("Is the child added in this layout?");
            }
            if (newPriority > oldPriority) {
                if (oldIndex == 0)
                    return;
                boolean inserted = false;
                for (int i = oldIndex - 1; i >= 0 ; i --) {
                    FakeView pre = children[i];
                    int prePriority = pre.priority;
                    if (prePriority > newPriority || (prePriority == newPriority && pre.index < child.index)) {
                        children[i + 1] = child;
                        inserted = true;
                        break;
                    }
                    children[i + 1] = pre;
                }
                if (!inserted) {
                    children[0] = child;
                }
            } else {
                if (oldIndex == childCount - 1)
                    return;
                boolean inserted = false;
                for (int i = oldIndex + 1; i < childCount; i ++) {
                    FakeView after = children[i];
                    int afterPriority = after.priority;
                    if (afterPriority < newPriority || (afterPriority == newPriority && after.index < child.index)) {
                        children[i - 1] = child;
                        inserted = true;
                        break;
                    }
                    children[i - 1] = after;
                }
                if (!inserted) {
                    children[childCount - 1] = child;
                }
            }
        }

        private void addViewToArray(FakeView child) {
            if (childCount == children.length) {
                resizeChildrenArray();
            }
            final int priority = child.priority;
            int insertIndex = childCount - 1;
            for ( ; insertIndex >= 0 ; insertIndex --) {
                if (children[insertIndex].priority >= priority) {
                    break;
                }
            }
            insertIndex ++;
            System.arraycopy(children, insertIndex, children, insertIndex + 1, childCount - insertIndex);
            children[insertIndex] = child;
            childCount ++;
        }

        private void removeViewFromArray(FakeView child) {
            boolean find = false;
            int index;
            for (index = 0; index < childCount; index ++) {
                if (!find && children[index] == child) {
                    find = true;
                } else if (find) {
                    children[index - 1] = children[index];
                }
            }
            children[childCount - 1] = null;
            childCount --;
        }

        private void resizeChildrenArray() {
            int old = children.length;
            int newlen = (int) (old * DEFAULT_LOAD_FACTOR) + old;
            FakeView[] temp = new FakeView[newlen];
            System.arraycopy(children, 0, temp, 0, old);
            children = temp;
        }

        @Override
        public String toString() {
            return Arrays.toString(children);
        }
    }

    static final class FakeView {
        int priority = 0;
        int index = 0;
        FakeLayout parent;
        public FakeView() {}
        public FakeView(int p) {
            priority = p;
        }

        public void changePriority(int p) {
            if (parent != null) {
                parent.onViewPriorityChanged(this, priority, p);
            }
            priority = p;
        }

        @Override
        public String toString() {
            return index + " " + priority;
        }
    }
}
