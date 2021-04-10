package com.pirsanth.rnimagewithprogressbar;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PorterDuff;
import android.media.Image;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.sql.Connection;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

import javax.net.ssl.HttpsURLConnection;

public class ImageWithSpinner extends RelativeLayout {
    private ImageView imageView;
    private ProgressBar spinner;
    private ProgressBar progressBar;
    private RelativeLayout parent;
    private String latestImageUrl;
    private String mode; //"bar" or "spinner"

    private ExecutorService executorService;
    private Handler mainThreadHandler;
    private Future latestFuture;
    boolean isLoadingImage;
    boolean hasContentLength;

    public ImageWithSpinner(Context context,
                            ExecutorService executorService,
                            Handler mainThreadHandler) {
        super(context);

        this.executorService = executorService;
        this.mainThreadHandler = mainThreadHandler;
        View inflatedView = LayoutInflater.from(context).inflate(R.layout.image_with_spinner_layout, this);
        spinner = inflatedView.findViewById(R.id.spinner);
        progressBar = inflatedView.findViewById(R.id.progressBar);
        imageView = inflatedView.findViewById(R.id.imageView);
        //setting the default mode of bar
        this.mode = "bar";
        this.hasContentLength = true;
        //this is so that if there is no imageUrl and they change the mode prop
        //the bar or the spinner will show
        this.isLoadingImage = true;
        //setting border with width 1px
//        this.setBackground(getResources().getDrawable(R.drawable.border));
    }

    public void setProgressBarColor(ColorStateList color){
        this.progressBar.setProgressTintList(color);
    }

    public void setProgressBackgroundColor(ColorStateList color){
        this.progressBar.setProgressBackgroundTintList(color);
        //this is to remove the background's transparency
        this.progressBar.setProgressBackgroundTintMode(PorterDuff.Mode.SRC);
    }

    public void updateTheImage(final Bitmap bitmap,final String urlOfBitmap){
        //use this bitmap if the image is too large
        //Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, 200, 200, false);//scale the bitmap

        //do on the main thread...
        this.mainThreadHandler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        //only update the image view if it is the latest url
                        if(ImageWithSpinner.this.latestImageUrl.equals(urlOfBitmap)){
                            ImageWithSpinner.this.isLoadingImage = false;
                            ImageWithSpinner.this.imageView.setImageBitmap(bitmap);
                            //now we hide the spinner AND the bar for simplicitys sake
                            ImageWithSpinner.this.progressBar.setVisibility(INVISIBLE);
                            ImageWithSpinner.this.spinner.setVisibility(INVISIBLE);
                        }
                    }
                }
        );
    }

    public void updateUIBasedOnModeAndContentLength(){
        if(this.mode.equals("bar")){
            if(this.hasContentLength){
                //show the bar
                this.progressBar.setVisibility(VISIBLE);
                this.spinner.setVisibility(INVISIBLE);
            } else {
                //show the spinner
                this.progressBar.setVisibility(INVISIBLE);
                this.spinner.setVisibility(VISIBLE);
            }
        }
        else if (mode.equals("spinner")) {
            //just show the spinner
            this.progressBar.setVisibility(INVISIBLE);
            this.spinner.setVisibility(VISIBLE);
        }
    }

    public void updateMode(String mode){

        this.mode = mode;
        //only show if the image is still loading
        if(this.isLoadingImage){
            this.updateUIBasedOnModeAndContentLength();
        }
    }

    public void updateProgress(float betweenZeroAndOne){
        //need to convert this into an int
        float percentWithDecimals = (float) betweenZeroAndOne*100;
        final int progress = Math.round(percentWithDecimals);

        this.mainThreadHandler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        ImageWithSpinner.this.progressBar.setProgress(progress);
                    }
                }
        );
    }

    public void sendOnLoadErrorToJsWithMessage(String message) {
        WritableMap event = Arguments.createMap();
        event.putString("errorMessage", message);
        ReactContext reactContext = (ReactContext)getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "internalHttpError",
                event);
    }


    public void loadUrlFromString(final String string){
        //if there is an image that is currently being downloaded, cancel it
        if(this.latestFuture != null){
            if(!this.latestFuture.isDone()){
                this.latestFuture.cancel(true);
            }
        }

        this.latestImageUrl = string;
        this.isLoadingImage = true;
        this.hasContentLength = true;

        //now we need to show either the bar or the spinner
        this.updateUIBasedOnModeAndContentLength();

        this.imageView.setImageBitmap(null);
        this.progressBar.setProgress(0);

        this.latestFuture = this.executorService.submit(new Runnable() {
            @Override
            public void run() {
                try {
                    URL url = new URL(string);
                      URLConnection connection =  url.openConnection();
                      connection.setRequestProperty("Accept", "image/*");
                      connection.connect();
                      int totalLength = connection.getContentLength();

                    //the first time it is run
                    if(totalLength == -1 && ImageWithSpinner.this.hasContentLength){
                        ImageWithSpinner.this.hasContentLength = false;
                        //do it on the main thread
                        ImageWithSpinner.this.mainThreadHandler.post(
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        ImageWithSpinner.this.updateUIBasedOnModeAndContentLength();
                                    }
                                }
                        );

                        String message = "The content-length http header for the given url is empty. This library cannot compute the progress of the image download without a content-length header";
                        //fires the error event on JS and keeps going
                        ImageWithSpinner.this.sendOnLoadErrorToJsWithMessage(message);
//                        throw new Exception(message);
                    }


//                    InputStream inputStream = url.openStream();
                    InputStream inputStream = connection.getInputStream();

                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

                    boolean keepLooping = true;
                    int totalAlreadyRead = 0;
                    while(keepLooping){
                        int maxAmountThatCanBeRead = inputStream.available();

                        int lengthOfByteArr;

                        if(maxAmountThatCanBeRead <=0){
                            //check if the content-length header is present
                            if(totalLength == -1){
                                lengthOfByteArr = 512;
                            } else {
                                lengthOfByteArr = totalLength;
                            }

                        } else {
                            lengthOfByteArr = maxAmountThatCanBeRead;
                        }
                        byte[] bytes = new byte[lengthOfByteArr];

                        int amountActuallyRead = inputStream.read(bytes);
                        //it may read less than the length/available or it might be -1
                        totalAlreadyRead += amountActuallyRead;


                        if(amountActuallyRead == -1){
                            keepLooping = false;
                            break;
                        }

                        //if there is a content-length, do the calculation for progress
                        if(totalLength != -1){
                            float percentageComplete  = (float) totalAlreadyRead/totalLength;
                            ImageWithSpinner.this.updateProgress(percentageComplete);
                        }

                        //put the bytes actually read into the output stream
                        outputStream.write(bytes,0, amountActuallyRead);
//                        outputStream.write(bytes,0, totalLength);
                    }
                    //display the results of the output stream in the image view
                    byte[] totalImage = outputStream.toByteArray();
                    Bitmap bitmap = BitmapFactory.decodeByteArray(totalImage,0, totalImage.length);
                    //check if the bitmap is empty if so, we throw an error
                    if(bitmap == null){
                        throw new Exception("Failed to decode an image from the data in the url. Are you sure the url returns an image?");
                    }
                    ImageWithSpinner.this.updateTheImage(bitmap, string);
                  } catch (Exception e) {
                    /*
                      event though the image is not loading, we do not set isLoadingImage
                      to false because we want the mode to update (progress bar to change into a spinner
                      and vice versa
                     */
                    ImageWithSpinner.this.sendOnLoadErrorToJsWithMessage(e.getMessage());
                    //send the error event...
                    e.printStackTrace();
                }
            }
        });
    }

}
