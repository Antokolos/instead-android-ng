#ifndef _ROTATOR_H
#define _ROTATOR_H
#include <jni.h>

class Rotator {
    private:
        JNIEnv* env;
        jclass cls;
    public:
        Rotator(JNIEnv* env, jclass cls);
        ~Rotator();

        void rotate_landscape();
        void rotate_portrait();
        void unlock_rotation();
};

#endif