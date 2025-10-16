#!/bin/bash
# XCAD Color Scheme Preview
# Run this script to see all colors in action

echo -e "\n🎨 XCAD Color Scheme Preview\n"

# Background info
echo -e "Background: #1A1A1A (Deep charcoal)"
echo -e "Foreground: #F1F1F1 (Bright white)\n"

# Function to display color
show_color() {
    local name=$1
    local code=$2
    local hex=$3
    printf "\e[${code}m%-20s\e[0m %s\n" "$name" "$hex"
}

echo "=== Standard Colors ==="
show_color "Black" "30" "#121212"
show_color "Red" "31" "#A52AFF"
show_color "Green" "32" "#7129FF"
show_color "Yellow" "33" "#3D2AFF"
show_color "Blue" "34" "#2B4FFF"
show_color "Purple/Magenta" "35" "#2883FF"
show_color "Cyan" "36" "#28B9FF"
show_color "White" "37" "#F1F1F1"

echo -e "\n=== Bright Colors ==="
show_color "Bright Black" "90" "#666666"
show_color "Bright Red" "91" "#BA5AFF"
show_color "Bright Green" "92" "#905AFF"
show_color "Bright Yellow" "93" "#685AFF"
show_color "Bright Blue" "94" "#5C78FF"
show_color "Bright Purple" "95" "#5EA2FF"
show_color "Bright Cyan" "96" "#5AC8FF"
show_color "Bright White" "97" "#FFFFFF"

echo -e "\n=== Text Examples ==="
echo -e "\e[31mError: Something went wrong\e[0m"
echo -e "\e[32mSuccess: Operation completed\e[0m"
echo -e "\e[33mWarning: Check your input\e[0m"
echo -e "\e[34mInfo: Processing data\e[0m"
echo -e "\e[36mDebug: Variable value = 42\e[0m"

echo -e "\n=== Bright Text Examples ==="
echo -e "\e[91m✗ Failed\e[0m"
echo -e "\e[92m✓ Passed\e[0m"
echo -e "\e[93m⚠ Warning\e[0m"
echo -e "\e[94mℹ Information\e[0m"
echo -e "\e[96m→ Next step\e[0m"

echo -e "\n=== Mixed Styles ==="
echo -e "\e[1;94mBold Blue\e[0m | \e[3;96mItalic Cyan\e[0m | \e[4;91mUnderline Red\e[0m"
echo -e "\e[1;32mBold Green\e[0m | \e[2;37mDim White\e[0m | \e[7;35mInverse Purple\e[0m"

echo -e "\n=== Rainbow Gradient ==="
echo -e "\e[34m█\e[94m█\e[36m█\e[96m█\e[35m█\e[95m█\e[31m█\e[91m█\e[33m█\e[93m█\e[32m█\e[92m█\e[0m"

echo -e "\n=== Sample Command Output ==="
echo -e "\e[96m$\e[0m ls -la"
echo -e "\e[34mdrwxr-xr-x\e[0m 5 user user 4096 Oct 16 12:00 \e[1;96m.\e[0m"
echo -e "\e[34mdrwxr-xr-x\e[0m 3 user user 4096 Oct 15 10:30 \e[1;96m..\e[0m"
echo -e "\e[32m-rw-r--r--\e[0m 1 user user 1234 Oct 16 11:45 \e[97mREADME.md\e[0m"
echo -e "\e[32m-rwxr-xr-x\e[0m 1 user user  567 Oct 16 12:00 \e[92msetup.sh\e[0m"

echo -e "\n✨ Color scheme preview complete!\n"
