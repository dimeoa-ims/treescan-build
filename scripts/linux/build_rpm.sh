#!/bin/bash
set -e

# Build TreeScan.jar and dist/lib directly, since the NetBeans ant build needs NetBeans-only tasks (CopyLibs).
cd /workspace/java_application/jni_application
rm -rf build dist
mkdir -p build/classes dist/lib
cp libs/*.jar dist/lib/
javac -encoding windows-1252 --release 25 -nowarn -d build/classes \
      -cp "$(echo libs/*.jar | tr ' ' ':')" $(find src -name '*.java')
cp images/* build/classes/

# Class-Path is wrapped onto continuation lines because the jar tool rejects manifest lines over 512 bytes.
cd dist
set -- lib/*.jar
{ printf 'Class-Path: %s\n' "$1"; shift; printf '  %s\n' "$@"; } > ../build/manifest.txt
cd ..
jar --create --file dist/TreeScan.jar --manifest build/manifest.txt \
    --main-class org.treescan.gui.TreeScanApplication -C build/classes .

/workspace/installers/jpackageInstallerLinux.sh "${VERSION#v}" /workspace/build/rpm /workspace \
    /workspace/build/binaries/linux "$JAVA_HOME" /workspace/build/jpackage
