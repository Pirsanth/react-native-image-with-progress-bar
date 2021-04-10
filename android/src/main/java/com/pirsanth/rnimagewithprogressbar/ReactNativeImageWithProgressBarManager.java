// ReactNativeImageWithProgressBarManager.java

package com.pirsanth.rnimagewithprogressbar;
// package com.pirsanth.rnimagewithprogressbar;
// package com.loadingimageios;

//start of dump
import android.content.res.ColorStateList;
import android.media.Image;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.ResourceCursorTreeAdapter;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.os.HandlerCompat;

import com.facebook.react.bridge.AssertionException;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.util.ExceptionDataHelper;
import com.facebook.react.util.RCTLog;
import com.facebook.react.common.JavascriptException;
import org.w3c.dom.Text;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;



public class ReactNativeImageWithProgressBarManager extends SimpleViewManager<ImageWithSpinner> {
    private ExecutorService executorService;
    private Handler mainThreadHandler;

    public ReactNativeImageWithProgressBarManager() {
        executorService = Executors.newCachedThreadPool();
        mainThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper());
    }

    public Map getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.builder()
                .put(
                        "internalHttpError",
                        MapBuilder.of(
                                "phasedRegistrationNames",
                                MapBuilder.of("bubbled", "onLoadError")))
                .build();
    }

    private ColorStateList getColorStateListWithInt(int colorInt){
        int[][] states = new int[][] {
                new int[] { android.R.attr.state_enabled}, // enabled
                new int[] {-android.R.attr.state_enabled}, // disabled
                new int[] {-android.R.attr.state_checked}, // unchecked
                new int[] { android.R.attr.state_pressed}  // pressed
        };

        int[] colors = new int[] {
                colorInt,
                colorInt,
                colorInt,
                colorInt
        };


        ColorStateList myList = new ColorStateList(states, colors);
        return myList;
    }


    @ReactProp(name = "barColorInt")
    public void setProgressBarColor(ImageWithSpinner view, int backgroundColor) {
        ColorStateList colorStateList = this.getColorStateListWithInt(backgroundColor);
        view.setProgressBarColor(colorStateList);
    }

    @ReactProp(name = "trackColorInt")
    public void setProgressBarBackgroundColor(ImageWithSpinner view, int backgroundColor) {
        ColorStateList colorStateList = this.getColorStateListWithInt(backgroundColor);
        view.setProgressBackgroundColor(colorStateList);
    }



    @ReactProp(name="mode")
    public void setMode(ImageWithSpinner view,String mode){
        //if null was passed we show the red box error
        if(mode == null){
            String message = "Wrong mode prop passed to an instance of the component exported by react-native-image-with-progress-bar\n\nAvailable modes are \"bar\" and \"spinner\"\n\nReceived: \"" +mode+"\"";
            throw new AssertionException(message);
        }


        if(mode.equals("spinner") || mode.equals("bar")){
            view.updateMode(mode);
        } else {
            String message = "Wrong mode prop passed to an instance of the component exported by react-native-image-with-progress-bar\n\nAvailable modes are \"bar\" and \"spinner\"\n\nReceived: \"" +mode+"\"";
            throw new AssertionException(message);
        }
    }

    @NonNull
    @Override
    public String getName() {
        return "ImageWithSpinner";
    }

    @NonNull
    @Override
    protected ImageWithSpinner createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new ImageWithSpinner(reactContext, this.executorService, this.mainThreadHandler);
    }

    @ReactProp(name="imageUrl")
    public void setImageUrl(ImageWithSpinner view, String string){
        view.loadUrlFromString(string);
    }
}