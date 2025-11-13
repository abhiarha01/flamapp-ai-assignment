plugins {
    id("com.android.application") version "8.5.0" apply false
    kotlin("android") version "1.9.24" apply false
}

allprojects {
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        options.encoding = "UTF-8"
    }
}
