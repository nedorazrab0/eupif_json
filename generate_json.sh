# get data
curl --parallel-immediate --parallel-max 0 -ZLo ./euapp.apk "$link"
aapt dump xmltree ./euapp.apk res/xml/inject_fields.xml > ./fields.txt

# generate json
echo -n > ./pif.json
for val in BRAND MANUFACTURER PRODUCT DEVICE MODEL SECURITY_PATCH FINGERPRINT; do
    key="$(grep -A2 "$val" ./fields.txt | sed -n 3p | awk -F '"' '{print $2}')"
    echo "$val ${key:-null}" >> pif.json
done

fp="$(grep 'FINGERPRINT' ./pif.json)"
echo "RELEASE $(echo $fp ./pif.json | awk -F '/' '{print $3}' | awk -F ':' '{print $2}')" >> ./pif.json
echo "INCREMENTAL $(echo $fp | awk -F '/' '{print $5}' | awk -F ':' '{print $1}')" >> ./pif.json
echo "ID $(echo $fp | awk -F '/' '{print $4}')" >> ./pif.json
echo "TYPE $(echo $fp | awk -F '/' '{print $5}' | awk -F ':' '{print $2}')" >> ./pif.json
echo "TAGS $(echo $fp | awk -F '/' '{print $6}')" >> ./pif.json

apilvl="$(grep -A2 "FIRST_API_LEVEL" ./fields.txt | sed -n 3p | awk -F '"' '{print $2}')"
if [[ -z "$apilvl" ]]; then
    echo 'DEVICE_INITIAL_SDK_INT 25' >> ./pif.json
else
    echo "DEVICE_INITIAL_SDK_INT $apilvl" >> pif.json
fi

# { "foo": "bar" }
awk -i inplace '{printf "    \"%s\": \"%s\"\,\n", $1, $2}' ./pif.json
sed -i '1i\{' ./pif.json
sed -i '$s/.$//' ./pif.json
echo '}' >> ./pif.json

# release pif.json
git config --global user.name 'github-actions'
git config --global user.email 'github-actions@github.com'
git add ./link.txt ./pif.json
git commit -m "New pif.json"
git push
