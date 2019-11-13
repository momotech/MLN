package com.mln.demo.android.entity;


import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-07 13:51
 */
public class HomeRvEntity implements Parcelable {

    private String sellernick;
    private String itempic;
    private String itemdesc;
    private String itemshorttitle;
    private String couponmoney;
    private String itemsale;
    private String general_index;
    private String taobao_image;

    public String getSellernick() {
        return sellernick;
    }

    public void setSellernick(String sellernick) {
        this.sellernick = sellernick;
    }

    public String getItempic() {
        return itempic;
    }

    public void setItempic(String itempic) {
        this.itempic = itempic;
    }

    public String getItemdesc() {
        return itemdesc;
    }

    public void setItemdesc(String itemdesc) {
        this.itemdesc = itemdesc;
    }

    public String getItemshorttitle() {
        return itemshorttitle;
    }

    public void setItemshorttitle(String itemshorttitle) {
        this.itemshorttitle = itemshorttitle;
    }

    public String getCouponmoney() {
        return couponmoney;
    }

    public void setCouponmoney(String couponmoney) {
        this.couponmoney = couponmoney;
    }

    public String getItemsale() {
        return itemsale;
    }

    public void setItemsale(String itemsale) {
        this.itemsale = itemsale;
    }

    public String getGeneral_index() {
        return general_index;
    }

    public void setGeneral_index(String general_index) {
        this.general_index = general_index;
    }

    public String getTaobao_image() {
        return taobao_image;
    }

    public void setTaobao_image(String taobao_image) {
        this.taobao_image = taobao_image;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.sellernick);
        dest.writeString(this.itempic);
        dest.writeString(this.itemdesc);
        dest.writeString(this.itemshorttitle);
        dest.writeString(this.couponmoney);
        dest.writeString(this.itemsale);
        dest.writeString(this.general_index);
        dest.writeString(this.taobao_image);
    }

    public HomeRvEntity() {
    }

    protected HomeRvEntity(Parcel in) {
        this.sellernick = in.readString();
        this.itempic = in.readString();
        this.itemdesc = in.readString();
        this.itemshorttitle = in.readString();
        this.couponmoney = in.readString();
        this.itemsale = in.readString();
        this.general_index = in.readString();
        this.taobao_image = in.readString();
    }

    public static final Creator<HomeRvEntity> CREATOR = new Creator<HomeRvEntity>() {
        @Override
        public HomeRvEntity createFromParcel(Parcel source) {
            return new HomeRvEntity(source);
        }

        @Override
        public HomeRvEntity[] newArray(int size) {
            return new HomeRvEntity[size];
        }
    };

    @Override
    public String toString() {
        return "HomeRvEntity{" +
                "sellernick='" + sellernick + '\'' +
                ", itempic='" + itempic + '\'' +
                ", itemdesc='" + itemdesc + '\'' +
                ", itemshorttitle='" + itemshorttitle + '\'' +
                ", couponmoney='" + couponmoney + '\'' +
                ", itemsale='" + itemsale + '\'' +
                ", general_index='" + general_index + '\'' +
                ", taobao_image='" + taobao_image + '\'' +
                '}';
    }
}
