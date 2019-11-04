package com.immomo.mls.fun.ud.view.viewpager;

import com.immomo.mls.fun.ud.view.UDViewGroup;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by fanqiang on 2018/8/30.
 */
@LuaApiUsed
public class UDViewPagerCell<T extends ViewPagerContent> extends UDViewGroup<T> {
    protected static final String WINDOW = "contentView";
    private LuaTable cell;

    public UDViewPagerCell(Globals globals) {
        super(globals);
        cell = LuaTable.create(globals);
        cell.set(WINDOW, this);
        view.setCell(cell);
    }

    @Override
    protected T newView(LuaValue[] init) {
        return (T) new ViewPagerContent(getContext(), this, null);
    }

    public LuaTable getCell() {
        return cell;
    }

    @Override
    protected String initLuaClassName(Globals g) {
        return g.getLuaClassName(UDViewGroup.class);
    }
}
