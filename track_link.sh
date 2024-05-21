while true; do
    link="$(curl -fs 'https://sourceforge.net/projects/xiaomi-eu-multilang-miui-roms/rss?path=/xiaomi.eu/Xiaomi.eu-app' | grep -om1 'https.*download')"
    if [[ "$link" && "$(cat ./link.txt)" != "$link" ]]; then
        echo "$link" > ./link.txt
        source ./generate_json.sh
    fi
    sleep 10
done
