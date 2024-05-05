# get apk
curl -fsZLo ./euapp.apk "$link"
apktool d --no-assets -fsbo ./euapp/ ./euapp.apk

# generate json
echo '{' > ./pif.json
for val in PRODUCT DEVICE MANUFACTURER BRAND MODEL FINGERPRINT SECURITY_PATCH FIRST_API_LEVEL; do
    key="$(grep "$val" ./euapp/res/xml/inject_fields.xml | awk -F 'value=' '{print $2}' | awk '{print $1}')"
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
