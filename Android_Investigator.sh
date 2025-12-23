#!/bin/bash

#################################################
# ANDROID MOBILE FORENSICS PARSER
# With Hacker-Style Glitching Mobile Animation
#################################################

set -e

# -------------------------------
# GLITCHING MOBILE ANIMATION
# -------------------------------
frames=(
"        .----------------.        
       |  .----.        |        
       | |####| |       |        
       | |####| |       |        
       | |####| |       |        
       | |####| |       |        
       |  '----'        |        
       '----------------'        
          ..::::..               "

"        .----------------.        
       |  .----.        |        
       | |#@@#| |       |        
       | |####| |       |        
       | |#$$#| |       |        
       | |####| |       |        
       |  '----'        |        
       '----------------'        
        ..::::::..              "

"        .----------------.        
       |  .----.        |        
       | |%%%%| |       |        
       | |@##@| |       |        
       | |####| |       |        
       | |##$#| |       |        
       |  '----'        |        
       '----------------'        
          .::..::..              "

"        .----------------.        
       |  .----.        |        
       | |####| |       |        
       | |#!!#| |       |        
       | |####| |       |        
       | |##**| |       |        
       |  '----'        |        
       '----------------'        
        ..::::::..              "
)

clear
for i in {1..2}; do
  for f in "${frames[@]}"; do
    clear
    echo -e "\e[32m$f\e[0m"
    sleep 0.15
  done
done

clear
echo "=============================================="
echo " ANDROID MOBILE FORENSICS PARSER"
echo "=============================================="
echo

read -rp "Enter Case ID: " CASE_ID
read -rp "Enter mounted Android image path: " IMG

if [ ! -d "$IMG" ]; then
    echo "[!] Invalid image path: $IMG"
    exit 1
fi

OUT="android_forensics_${CASE_ID}_$(date +%F_%H%M%S)"
mkdir -p "$OUT"/{csv,analysis}

echo
echo "[+] Case ID       : $CASE_ID"
echo "[+] Evidence Path : $IMG"
echo "[+] Output Dir    : $OUT"
echo

#################################################
# 1. INTEGRITY VERIFICATION
#################################################
echo "[+] Hashing evidence (SHA-256)..."
find "$IMG" -type f -exec sha256sum {} \; 2>/dev/null > "$OUT/evidence_hashes.txt"
echo "[+] Hashing complete"
echo

#################################################
# 2. CALL LOGS
#################################################
CALL_DB="$IMG/data/data/com.android.providers.contacts/databases/calllog.db"

if [ -f "$CALL_DB" ]; then
    echo "[+] Extracting call logs..."
    sqlite3 -csv "$CALL_DB" \
    "SELECT datetime(date/1000,'unixepoch') AS time,
            number,
            duration,
            type
     FROM calls;" > "$OUT/csv/call_logs.csv"
    column -s, -t "$OUT/csv/call_logs.csv" > "$OUT/call_logs.txt"
else
    echo "[!] Call log DB not found: $CALL_DB"
fi

#################################################
# 3. SMS
#################################################
SMS_DB="$IMG/data/data/com.android.providers.telephony/databases/mmssms.db"

if [ -f "$SMS_DB" ]; then
    echo "[+] Extracting SMS messages..."
    sqlite3 -csv "$SMS_DB" \
    "SELECT datetime(date/1000,'unixepoch') AS time,
            address,
            body
     FROM sms;" > "$OUT/csv/sms_messages.csv"
    column -s, -t "$OUT/csv/sms_messages.csv" > "$OUT/sms_messages.txt"
else
    echo "[!] SMS DB not found: $SMS_DB"
fi

#################################################
# 4. CONTACTS
#################################################
CONTACT_DB="$IMG/data/data/com.android.providers.contacts/databases/contacts2.db"

if [ -f "$CONTACT_DB" ]; then
    echo "[+] Extracting contacts..."
    sqlite3 -csv "$CONTACT_DB" \
    "SELECT display_name FROM raw_contacts WHERE display_name IS NOT NULL;" \
    > "$OUT/csv/contacts.csv"
    column -s, -t "$OUT/csv/contacts.csv" > "$OUT/contacts.txt"
else
    echo "[!] Contacts DB not found: $CONTACT_DB"
fi

#################################################
# 5. BROWSER HISTORY (CHROME)
#################################################
CHROME_DB="$IMG/data/data/com.android.chrome/app_chrome/Default/History"

if [ -f "$CHROME_DB" ]; then
    echo "[+] Extracting Chrome history..."
    sqlite3 -csv "$CHROME_DB" \
    "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch') AS visit_time,
            url FROM urls;" \
    > "$OUT/csv/browser_history.csv"
    column -s, -t "$OUT/csv/browser_history.csv" > "$OUT/browser_history.txt"
else
    echo "[!] Chrome DB not found: $CHROME_DB"
fi

#################################################
# 6. INSTALLED APPS
#################################################
PKG_XML="$IMG/data/system/packages.xml"

if [ -f "$PKG_XML" ]; then
    echo "[+] Listing installed apps..."
    grep 'package name=' "$PKG_XML" | sed 's/.*name="\([^"]*\)".*/\1/' | sort > "$OUT/installed_apps.txt"
else
    echo "[!] packages.xml not found: $PKG_XML"
fi

#################################################
# 7. BASIC STATISTICS
#################################################
echo "[+] Generating basic statistics..."

if [ -f "$OUT/csv/call_logs.csv" ]; then
    awk -F, '{print $2}' "$OUT/csv/call_logs.csv" | sort | uniq -c | sort -nr > "$OUT/analysis/top_called_numbers.txt"
fi

if [ -f "$OUT/csv/sms_messages.csv" ]; then
    awk -F, '{print $2}' "$OUT/csv/sms_messages.csv" | sort | uniq -c | sort -nr > "$OUT/analysis/top_sms_senders.txt"
fi

#################################################
# 8. UNIFIED TIMELINE
#################################################
echo "[+] Building unified timeline..."

{
    [ -f "$OUT/csv/call_logs.csv" ] && awk -F, '{print $1,"CALL",$2}' "$OUT/csv/call_logs.csv"
    [ -f "$OUT/csv/sms_messages.csv" ] && awk -F, '{print $1,"SMS",$2}' "$OUT/csv/sms_messages.csv"
    [ -f "$OUT/csv/browser_history.csv" ] && awk -F, '{print $1,"WEB",$2}' "$OUT/csv/browser_history.csv"
} | sort > "$OUT/analysis/unified_timeline.txt"

if [ ! -s "$OUT/analysis/unified_timeline.txt" ]; then
    echo "[!] Unified timeline is empty. Check if CSV files were generated."
fi

#################################################
# 9. WHATSAPP ANALYSIS (EXTENSION)
#################################################
WA_DB="$IMG/data/data/com.whatsapp/databases/msgstore.db"

if [ -f "$WA_DB" ]; then
    echo "[+] Extracting WhatsApp messages..."
    sqlite3 "$WA_DB" \
    "SELECT datetime(timestamp/1000,'unixepoch'), data FROM messages WHERE data IS NOT NULL;" \
    > "$OUT/analysis/whatsapp_messages.txt"

    grep -Eo 'https?://[^ ]+' "$OUT/analysis/whatsapp_messages.txt" > "$OUT/analysis/whatsapp_urls.txt"
else
    echo "[!] WhatsApp DB not found: $WA_DB"
fi

#################################################
# FINAL SUMMARY
#################################################
echo
echo "=============================================="
echo "[✔] FORENSIC ANALYSIS COMPLETE"
echo "=============================================="
echo "[✔] Output directory: $OUT"
echo "=============================================="
                                                       
