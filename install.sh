#!/bin/bash

BASE_DIR="$1"
PACKAGE_PARSER=${BASE_DIR/"$2/src/main/java/com/"/""}
PACKAGES=""

IFS='/' read -ra ARRAY <<<"$PACKAGE_PARSER"
I=0

for PART in "${ARRAY[@]}"; do
    if [ "$I" == "0" ]; then
        PACKAGES="$PART"
    fi

    if [ "$I" == "1" ]; then
        PACKAGES="${PACKAGES}.${PART}"
    fi

    I=$((I + 1))
done

CLASSES=(
    "$1/History.java"
    "$1/HistoryHandler.java"
    "$1/HistoryHandlerImpl.java"
    "$1/HistorySubscriber.java"
    "$1/HistoryConfigurer.java"
)

for CLASS in "${CLASSES[@]}"; do
    sed -i "s|replace.replace|$PACKAGES|" "$CLASS"
done


DIRECTORY="$2/src/main/java/com/${PACKAGES//.//}/configuration/history"

if [ ! -d "$DIRECTORY" ]; then
    mkdir -p "$DIRECTORY"
fi

if [ -f "$DIRECTORY/HistoryConfigurerImpl.java" ]; then
    read -p "File $DIRECTORY/HistoryConfigurerImpl.java, Overwrite ? [Y/n] " -r OVERWRITE

    if [ "$OVERWRITE" == "Y" ] || [ "$OVERWRITE" == "y" ]; then
        mv "$1/config/HistoryConfigurerImpl.java" "$DIRECTORY/HistoryConfigurerImpl.java"
    fi

else
    mv "$1/config/HistoryConfigurerImpl.java" "$DIRECTORY/HistoryConfigurerImpl.java"
fi


sed -i "s|com.$PACKAGES.api.history.config;|com.${PACKAGES}.configuration.history;|" "$DIRECTORY/HistoryConfigurerImpl.java"

rm -Rf "$1/config"