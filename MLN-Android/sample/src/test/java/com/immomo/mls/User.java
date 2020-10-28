package com.immomo.mls;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-19 12:15
 */





public class User extends Person {
    private String name;


    public String getName() {
        return name;
    }

    public void setName(String name) {
        String old = this.name;
        this.name = name;
        notifyPropertyChanged("name",old,this.name);

    }
}



class Person extends PropertyObservable{

}


class PropertyObservable {

    public void notifyPropertyChanged(String fieldName,Object older,Object newer) {}

}













