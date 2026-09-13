// Top-level build file — configuration is per-module.
//
// AGP 9 has built-in Kotlin support, so `org.jetbrains.kotlin.android` is not
// applied. AGP pins KGP to its own baseline, so upgrading it is done here on
// the buildscript classpath.
buildscript {
    dependencies {
        classpath(libs.kotlin.gradle.plugin)
    }
}

plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.compose) apply false
}
