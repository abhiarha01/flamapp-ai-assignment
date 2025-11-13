#!/usr/bin/env sh

# Gradle start up script for UN*X

APP_BASE_NAME=${0##*/}
APP_HOME=$(dirname "$0")

# resolve symlinks
PRG=$0
while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

# If wrapper jar missing, try bootstrap script
if [ ! -f "$CLASSPATH" ]; then
  if [ -x "$APP_HOME/scripts/bootstrap_gradle_wrapper.sh" ]; then
    "$APP_HOME/scripts/bootstrap_gradle_wrapper.sh"
  fi
fi

if [ ! -f "$CLASSPATH" ]; then
  echo "Gradle wrapper jar not found. Run scripts/bootstrap_gradle_wrapper.sh first." >&2
  exit 1
fi

org.gradle.jvmargs="-Xmx1g -Dfile.encoding=UTF-8"

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME" >&2
        exit 1
    fi
else
    JAVACMD="java"
fi

# Pass all arguments to Gradle Wrapper main class
exec "$JAVACMD" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
