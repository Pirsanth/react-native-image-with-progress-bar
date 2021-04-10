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
//in production
import processColor from "../react-native/Libraries/StyleSheet/processColor.js";


const WrappedComponent = (props) => {
    //seperate the style props from the other props
    //however I do not want to directly mutate the passed in props so i make a shallow copy here
    //wrapping the component with a view is so that the border attributes in the style prop work
    const propsWithoutStyleAndOnLoadError = {
        ...props,
    };
    delete propsWithoutStyleAndOnLoadError['style'];
    delete propsWithoutStyleAndOnLoadError['onLoadError'];
    

    //deal with the situation where he passes in an array or an object
    //append ovefow: "hidden"  
    var styleToUse = null;
    if(typeof props.style === "object"){
      //is it an object or an array  
      //its an array
      if(props.style instanceof Array){
        styleToUse = [
          ...props.style,
          {overflow: 'hidden'}
        ];
      } 
      //it is an object
      else {
        styleToUse = {
          ...props.style,
          overflow: 'hidden'
        }
      }
    } 
    //an object or an array was not received...
    //it will simply make the image take up the full width and height of its container
    else {

    }

    const barColorInt = props.barColor && processColor(props.barColor);
    const trackColorInt = props.trackColor && processColor(props.trackColor);

    return (
        <View
          style={styleToUse}
          >
              <NativeComponent 
                {...propsWithoutStyleAndOnLoadError} 
                onLoadError={(props.onLoadError)?(e)=> {props.onLoadError(e.nativeEvent)} : () =>{}}               
                //the barColor and trackColor props do not matter as 
                //nothing on the Native side is listening for it
                barColorInt={barColorInt}
                trackColorInt={trackColorInt}    
                style={{
                  width: '100%',
                  height: '100%'
                }}
              />
          </View>
    )
}






export default WrappedComponent;
