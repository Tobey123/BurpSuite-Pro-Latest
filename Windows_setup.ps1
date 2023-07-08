# Name is Important
write-host "  .d8888b.           888       .d8888b.               8888888888P                  888    " -foregroundcolor "Red"
write-host " d88P  Y88b          888      d88P  Y88b                    d88P                   888    " -foregroundcolor "Red"
write-host " 888    888          888           .d88P                   d88P                    888    " -foregroundcolor "Red"
write-host " 888        888  888 88888b.      8888'  888d888          d88P    .d88b.  .d8888b  888888 " -foregroundcolor "Red"
write-host " 888        888  888 888 '88b      'Y8b. 888P'           d88P    d8P  Y8b 88K      888    " -foregroundcolor "white"
write-host " 888    888 888  888 888  888 888    888 888            d88P     88888888 'Y8888b. 888    " -foregroundcolor "white"
write-host " Y88b  d88P Y88b 888 888 d88P Y88b  d88P 888           d88P      Y8b.          X88 Y88b.  " -foregroundcolor "white"
write-host "  'Y8888P'   'Y88888 88888P'   'Y8888P'  888          d8888888888 'Y8888   88888P'  'Y888 " -foregroundcolor "green"
write-host "                 888                                                                      " -foregroundcolor "green"
write-host "            Y8b d88P                                                                      " -foregroundcolor "green"
write-host "             'Y88P'                                                                       " -foregroundcolor "green"

echo "  This script is made by Cyber Zest"
# Set Wget Progress to Silent, Becuase it slows down Downloading by 50x
echo "Setting Wget Progress to Silent, Becuase it slows down Downloading by 50x`n"
$ProgressPreference = 'SilentlyContinue'

# Check JDK-18 or 19 Availability or Download JDK-18 or 19
$jdk19 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java(TM) SE Development Kit 19*"
if (!($jdk19)){
    echo "`t`tDownnloading Java JDK-19 ...."
    wget "https://download.oracle.com/java/19/latest/jdk-19_windows-x64_bin.exe" -O jdk-19.exe  
    echo "`n`t`tJDK-19 Downloaded, lets start the Installation process"
    start -wait jdk-19.exe
    rm jdk-19.exe
}else{
    echo "Required JDK-19 is Installed"
    $jdk19
}

# Check JRE-8 Availability or Download JRE-8
$jre8 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java 8 Update *"
if (!($jre8)){
    echo "`n`t`tDownloading Java JRE ...."
    wget "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=246474_2dee051a5d0647d5be72a7c0abff270e" -O jre-8.exe
    echo "`n`t`tJRE-8 Downloaded, lets start the Installation process"
    start -wait jre-8.exe
    rm jre-8.exe
}else{
    echo "`n`nRequired JRE-8 is Installed`n"
    $jre8
}

# Downloading Burp Suite Professional
if (Test-Path burpsuite_pro_v*.jar){
    echo "Burp Suite Professional JAR file is available.`nChecking its Integrity ...."
    if (((Get-Item burpsuite_pro_v*.jar).length/1MB) -lt 500 ){
        echo "`n`t`tFiles Seems to be corrupted `n`t`tDownloading Latest Burp Suite Professional ...."
		$version = (Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/community/latest" -UseBasicParsing).Links.href | Select-String -Pattern "product=pro&amp;version=*" | Select-Object -First 1 | ForEach-Object { [regex]::Match($_, '\d+\.\d+\.\d+').Value }
		wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar" -O "burpsuite_pro_v$version.jar"
        echo "`nBurp Suite Professional is Downloaded.`n"
    }else {echo "File Looks fine. Lets proceed for Execution"}
}else {
    echo "`n`t`tDownloading Latest Burp Suite Professional ...."
	$version = (Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/community/latest" -UseBasicParsing).Links.href | Select-String -Pattern "product=pro&amp;version=*" | Select-Object -First 1 | ForEach-Object { [regex]::Match($_, '\d+\.\d+\.\d+').Value }
	wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar" -O "burpsuite_pro_v$version.jar"
    echo "`nBurp Suite Professional is Downloaded.`n"
}

# Creating Burp.bat file with command for execution
if (Test-Path burp.bat) {rm burp.bat}
$path = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:`"$pwd\loader.jar`" -noverify -jar `"$pwd\burpsuite_pro_v$version.jar`""
$path | add-content -path Burp.bat
echo "`nBurp.bat file is created"


# Creating Burp-Suite-Pro.vbs File for background execution
if (Test-Path Burp-Suite-Pro.vbs) {
   Remove-Item Burp-Suite-Pro.vbs}
echo "Set WshShell = CreateObject(`"WScript.Shell`")" > Burp-Suite-Pro.vbs
add-content Burp-Suite-Pro.vbs "WshShell.Run chr(34) & `"$pwd\Burp.bat`" & Chr(34), 0"
add-content Burp-Suite-Pro.vbs "Set WshShell = Nothing"
echo "`nBurp-Suite-Pro.vbs file is created."

# Remove Additional files
rm Linux_setup.sh
del -Recurse -Force .\.github\


# Lets Activate Burp Suite Professional with keygenerator and Keyloader
echo "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
echo "`n`nStarting Keygenerator ...."
start-process java.exe -argumentlist "-jar loader.jar"
echo "`n`nStarting Burp Suite Professional"
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:"loader.jar" -noverify -jar "burpsuite_pro_v$version.jar"
