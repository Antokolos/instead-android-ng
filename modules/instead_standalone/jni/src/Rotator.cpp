#include "Rotator.h"
#include <jni.h>

Rotator::Rotator(JNIEnv* env, jclass cls, jobject obj) {
    this->env = env;
    this->cls = cls;
    this->obj = obj;
}

void Rotator::rotate_landscape() {
    JNIEnv* env = this->env;
    jmethodID rotateLandscape = env->GetMethodID(this->cls, "rotateLandscape", "()V");
    env->CallObjectMethod(this->obj, rotateLandscape, 0);
}

void Rotator::rotate_portrait() {
    JNIEnv* env = this->env;
    jmethodID rotatePortrait = env->GetMethodID(this->cls, "rotatePortrait", "()V");
    env->CallObjectMethod(this->obj, rotatePortrait, 0);
}

void Rotator::unlock_rotation() {
    JNIEnv* env = this->env;
    jmethodID unlockRotation = env->GetMethodID(this->cls, "unlockRotation", "()V");
    env->CallObjectMethod(this->obj, unlockRotation, 0);
}