import { requireNativeComponent } from 'react-native';
import React, { useState } from 'react';
import {
    Button,
    SafeAreaView,
    ScrollView,
    StatusBar,
    StyleSheet,
    Text,
    useColorScheme,
    View,
    Image
  } from 'react-native';
const NativeComponent = requireNativeComponent('ImageWithSpinner');
//in dev
// import processColor from "./node_modules/react-native/Libraries/StyleSheet/processColor.js";
//in npm module
import processColor from "../react-native/Libraries/StyleSheet/processColor.js";


const WrappedComponent = (props) => {    

    const barColorInt = props.barColor && processColor(props.barColor);
    const trackColorInt = props.trackColor && processColor(props.trackColor);
    
    const propsWithoutOnLoadError = {
      ...props,
    };
    delete propsWithoutOnLoadError['onLoadError'];


    return (
              <NativeComponent 
                {...propsWithoutOnLoadError}                
                onLoadError={(props.onLoadError)?(e)=> {props.onLoadError(e.nativeEvent)} : () =>{}}
                //the barColor and trackColor props do not matter as 
                //nothing on the Native side is listening for it
                barColorInt={barColorInt}
                trackColorInt={trackColorInt}    
              />
    )
}






export default WrappedComponent;
