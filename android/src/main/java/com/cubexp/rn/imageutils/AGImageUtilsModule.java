package com.cubexp.rn.imageutils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.io.File;
import java.io.FileOutputStream;

public class AGImageUtilsModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public AGImageUtilsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "AGImageUtils";
    }

    @ReactMethod
    public void crop(String path, ReadableMap options, Promise promise) {
        int x = options.hasKey("x") ? options.getInt("x") : 0;
        int y = options.hasKey("y") ? options.getInt("y") : 0;
        int width = options.getInt("width");
        int height = options.getInt("height");
        int destWidth = options.hasKey("dest_width") ? options.getInt("dest_width") : width;
        int destHeight = options.hasKey("dest_height") ? options.getInt("dest_height") : height;
        int quality = options.hasKey("quality") ? options.getInt("quality") : 100;
        String savePath = options.getString("save_path");

        String format = options.hasKey("format") ? options.getString("format") : "jpg";
        Bitmap.CompressFormat compressFormat = Bitmap.CompressFormat.JPEG;
        if ("png".equalsIgnoreCase(format)) {
            compressFormat = Bitmap.CompressFormat.PNG;
        } else if ("webp".equalsIgnoreCase(format)) {
            compressFormat = Bitmap.CompressFormat.WEBP;
        }

        Bitmap cropped = Bitmap.createBitmap(new BitmapFactory().decodeFile(path), x, y, width, height);
        if (width != destWidth || height != destHeight) {
            cropped = Bitmap.createScaledBitmap(cropped, destWidth, destHeight, true);
        }

        FileOutputStream out = null;
        File dest = new File(savePath);

        try {
            out = new FileOutputStream(dest);
            cropped.compress(compressFormat, quality, out);
            promise.resolve(dest.getAbsolutePath());
        } catch (Exception e) {
            promise.reject("Failed to save", "Failed to save to file", null);
        } finally {
            try {
                out.close();
            } catch (Exception e) {
                promise.reject("Failed to save", "Failed to close saved file stream", null);
            }
        }
    }
}
