# Keep native methods (JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep OpenCV classes
-keep class org.opencv.** { *; }

# Keep our native processor bridge
-keep class com.flamapp.ai.nativebridge.** { *; }

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
