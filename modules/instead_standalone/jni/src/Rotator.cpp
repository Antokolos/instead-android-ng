#include "Rotator.h"
#include <jni.h>
#include <stdio.h>

Rotator* pRotator = NULL;

extern "C" void rotate_portrait() {
    if (pRotator) {
        pRotator->rotate_portrait();
    }
}

extern "C" void rotate_landscape() {
    if (pRotator) {
        pRotator->rotate_landscape();
    }
}

extern "C" void unlock_rotation() {
    if (pRotator) {
        pRotator->unlock_rotation();
    }
}

Rotator::Rotator(JNIEnv* env, jclass cls) {
    this->env = env;
    this->cls = cls;
    pRotator = this;
}

Rotator::~Rotator() {
    pRotator = NULL;
}

void Rotator::rotate_landscape() {
    JNIEnv* env = this->env;
    jmethodID rotateLandscape = env->GetStaticMethodID(this->cls, "rotateLandscape", "()V");
    if (rotateLandscape) {
        env->CallStaticVoidMethod(this->cls, rotateLandscape);
    } else {
        printf("rotateLandscape() method not found in the SDLActivity class!\n");
    }
}

void Rotator::rotate_portrait() {
    JNIEnv* env = this->env;
    jmethodID rotatePortrait = env->GetStaticMethodID(this->cls, "rotatePortrait", "()V");
    if (rotatePortrait) {
        env->CallStaticVoidMethod(this->cls, rotatePortrait);
    } else {
        printf("rotatePortrait() method not found in the SDLActivity class!\n");
    }
}

void Rotator::unlock_rotation() {
    JNIEnv* env = this->env;
    jmethodID unlockRotation = env->GetMethodID(this->cls, "unlockRotation", "()V");
    if (unlockRotation) {
        env->CallStaticVoidMethod(this->cls, unlockRotation);
    } else {
        printf("unlockRotation() method not found in the SDLActivity class!\n");
    }
}