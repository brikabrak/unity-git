#!/bin/sh

UNITY_VERSION=''
UNITY_PATH_MAC='/Applications/Unity'
HUB_PATH='/Hub/Editor'
MERGE_TOOL_PATH='/Unity.app/Contents/Tools/UnityYAMLMerge'

TOOL_PATH=""

if [ -d "$UNITY_PATH_MAC" ]; then
    if [ -d "$UNITY_PATH_MAC$HUB_PATH" ]; then
        UNITY_VERSION="/$(ls $UNITY_PATH_MAC$HUB_PATH | tail -n 1)"
        TOOL_PATH="$UNITY_PATH_MAC$HUB_PATH"
    elif [ -d "$UNITY_PATH_MAC$UNITY_VERSION" ]; then
        TOOL_PATH="$UNITY_PATH_MAC"
    fi
fi

TOOL_PATH="$TOOL_PATH$UNITY_VERSION$MERGE_TOOL_PATH"

if [ ! -f "$TOOL_PATH" ]; then
    echo "No Merge tool to use at $TOOL_PATH"
    exit 1
fi

# Mac Only!
LFS_INSTALL="$(brew list git-lfs | grep bin/git-lfs )"
echo $LFS_INSTALL
if [[ $LFS_INSTALL = "Error*" || ! -f $LFS_INSTALL ]]; then
    echo "No git lfs, installing via brew..."
    brew install git-lfs
fi

curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Unity.gitignore

echo $'*.psd\n*.png\n*.mp3\n*.wav\n*.prefab\n*.fbx\n*.xcf\n*.blend\n*.obj\n*.3ds\n*.dae' > .gitattributes
sed -e 's/\(\*\.\w\+\)/\1 filter=lfs diff=lfs merge=lfs -text\n/' .gitattributes > a.tmp && mv a.tmp .gitattributes

printf $'[merge]\ntool = unityyamlmerge\n\n[mergetool "unityyamlmerge"]\ntrustExitCode = false\ncmd = \'' > .gitconfig && printf "$TOOL_PATH" >> .gitconfig && printf $'\' "$BASE" "$REMOTE" "$LOCAL" "$MERGED"\n' >> .gitconfig

git init
git lfs install

echo "~~Finished git setup for Unity~~~"
echo "Make sure to set the Unity project settings correctly!"

exit 0
