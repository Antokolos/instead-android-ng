# JNI-мост SDL
-keep class org.libsdl.app.** { *; }
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

-keep class com.nlbhub.instead.** { *; }

-dontwarn org.apache.commons.io.**

-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
