# JNI-мост SDL
-keep class org.libsdl.app.** { *; }
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Точки входа приложения и движка
-keep class com.nlbhub.instead.** { *; }

# Вендоренный commons-io
-dontwarn org.apache.commons.io.**

# Читаемые стектрейсы
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
