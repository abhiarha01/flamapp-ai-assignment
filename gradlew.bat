@ECHO OFF

SETLOCAL
SET DIR=%~dp0
SET WRAPPER_JAR=%DIR%gradle\wrapper\gradle-wrapper.jar

IF NOT EXIST "%WRAPPER_JAR%" (
  IF EXIST "%DIR%scripts\bootstrap_gradle_wrapper.ps1" (
    powershell -ExecutionPolicy Bypass -File "%DIR%scripts\bootstrap_gradle_wrapper.ps1"
  )
)

IF NOT EXIST "%WRAPPER_JAR%" (
  ECHO Gradle wrapper jar not found. Run scripts\bootstrap_gradle_wrapper.ps1 first.
  EXIT /B 1
)

SET JAVA_EXE=java
IF DEFINED JAVA_HOME SET JAVA_EXE="%JAVA_HOME%\bin\java.exe"

"%JAVA_EXE%" -classpath "%WRAPPER_JAR%" org.gradle.wrapper.GradleWrapperMain %*
