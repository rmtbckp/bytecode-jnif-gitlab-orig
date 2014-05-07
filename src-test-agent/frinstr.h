#ifndef __FRINSTR_H__
#define	__FRINSTR_H__

/**
 *
 */
#include <string.h>
#include <stdbool.h>

#include <jvmti.h>

#define FR_PROXY_CLASS "frproxy/FrInstrProxy"

static inline bool FrIsProxyClassName(const char* className) {
	return strcmp(className, FR_PROXY_CLASS) == 0;
}

static inline bool FrIsProxyClassSignature(const char* classSignature) {
	return strcmp(classSignature, "L" FR_PROXY_CLASS ";") == 0;
}

void FrSetInstrHandlerNatives(jvmtiEnv* jvmti, JNIEnv* jni, jclass klass);
void FrSetInstrHandlerJvmtiEnv(jvmtiEnv* jvmti);

typedef struct __InstrArgsTag {
	jobject loader;
} InstrArgs;

#endif
