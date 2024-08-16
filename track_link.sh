while true; do
    source ./saved_link.sh
    link="$(curl --parallel-immediate --parallel-max 0 -fsZ 'https://sourceforge.net/projects/xiaomi-eu-multilang-miui-roms/rss?path=/xiaomi.eu/Xiaomi.eu-app' | grep -om1 'https.*download')"
    if [[ -n "$link" && "$link" != "$saved_link" ]]; then
        echo "saved_link=${link}" > ./saved_link.sh
        sleep 5
        source ./generate_json.sh
    fi
    sleep 60
done
