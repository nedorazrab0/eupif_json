# get apk
curl -ZLo ./euapp.apk "$link"
aapt dump xmltree euapp.apk res/xml/inject_fields.xml > ./fields.xml

# generate json
echo '{' > ./pif.json
for val in PRODUCT DEVICE MANUFACTURER BRAND MODEL FINGERPRINT SECURITY_PATCH FIRST_API_LEVEL; do
    key="$(grep -A2 "$val" ./fields.xml | sed -n 3p | awk -F 'value=' '{print $2}' | awk '{print $1}')"
    echo "    \"$val\": ${key:-\"null\"}," >> ./pif.json
done
sed -i '$s/.$//' ./pif.json
echo '}' >> ./pif.json

# release pif.json
git config --global user.name 'github-actions'
git config --global user.email 'github-actions@github.com'
git add ./link.txt ./pif.json
git commit -m 'New pif.json'
git push
