#!/bin/bash

    # Download Burp Suite Profesional Latet Version
    echo 'Downloading Burp Suite Professional Latest....'
    mkdir -p /usr/share/burpsuite
    cp loader.jar /usr/share/burpsuite/
    cp burp_suite.ico /usr/share/burpsuite/
    cd /usr/share/burpsuite/
    html=$(curl -s https://portswigger.net/burp/releases)
    version=$(echo $html | grep -Po '(?<=/burp/releases/professional-community-)[0-9]+\-[0-9]+\-[0-9]+' | head -n 1)
    Link="https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar"
    echo $version
    wget "$Link" -O burpsuite_pro_v$version.jar --quiet --show-progress
    sleep 2s
    
    # Execute Burp Suite Professional with Keyloader
    echo 'Executing Burp Suite Professional with Keyloader'
    echo "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/loader.jar -noverify -jar $(pwd)/burpsuite_pro_v$version.jar &" > burpsuite
    chmod +x burpsuite
    cp burpsuite /bin/burpsuite

    # execute Keygenerator
    echo 'Starting Keygenerator'
    (java -jar loader.jar) &
    sleep 3s
    (./burpsuite)
else
    echo "Execute Command as Root User"
    exit
