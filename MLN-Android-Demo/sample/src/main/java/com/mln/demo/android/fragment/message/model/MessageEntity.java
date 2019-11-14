package com.mln.demo.android.fragment.message.model;

import android.os.Parcel;
import android.os.Parcelable;

public class MessageEntity implements Parcelable {
    /**
     * femalename : ﻿花花世界丶小风流
     */

    private String femalename;


    private String icon;

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getFemalename() {
        return femalename;
    }

    public void setFemalename(String femalename) {
        this.femalename = femalename;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.femalename);
        dest.writeString(this.icon);
    }

    public MessageEntity() {

    }

    protected MessageEntity(Parcel in) {
        this.femalename = in.readString();
        this.icon = in.readString();
    }

    public static final Creator<MessageEntity> CREATOR = new Creator<MessageEntity>() {
        @Override
        public MessageEntity createFromParcel(Parcel source) {
            return new MessageEntity(source);
        }

        @Override
        public MessageEntity[] newArray(int size) {
            return new MessageEntity[size];
        }
    };

}
