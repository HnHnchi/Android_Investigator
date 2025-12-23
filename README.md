###Android Mobile Forensics Parser

A bash-based forensic analysis tool for Android devices, featuring a hacker-style glitching mobile animation and automated extraction of key artifacts from a mounted Android image. This tool is designed for investigators, researchers, and security enthusiasts to quickly analyze Android devices in a structured and automated way.

###Features
```

Animated "glitching mobile" ASCII intro for visual flair.

Extracts key forensic artifacts from Android images:

Call logs

SMS messages

Contacts

Browser history (Chrome)

Installed apps

WhatsApp messages (optional)

Computes SHA-256 hashes of all files for integrity verification.
```

###Generates:
```

CSV files for easy analysis

Plain-text reports

Basic statistics and top contacts/SMS senders

Unified timeline of calls, SMS, and web history

Requirements

Linux or macOS environment (bash shell)

Installed tools:

sqlite3

awk

grep

column

sha256sum

A mounted Android image with read access to the /data partition.
```

###Usage

Clone or download the script to your local machine:
```
git clone <repository_url>
cd android-forensics-parser
chmod +x android_forensics_parser.sh
```


###Run the script:
```

./Android_Investigator.sh
```


###Follow the prompts:
```

Enter a Case ID (used to name the output folder)

Enter the path to your mounted Android image

The tool will:

Display the glitching animation

Hash all files in the image

Extract forensic artifacts

Generate CSVs, text reports, statistics, and a unified timeline

Output files to a timestamped folder: android_forensics_<CASE_ID>_<timestamp>
```

###Output Structure
```
android_forensics_<CASE_ID>_<timestamp>/
├── csv/
│   ├── call_logs.csv
│   ├── sms_messages.csv
│   ├── contacts.csv
│   └── browser_history.csv
├── analysis/
│   ├── top_called_numbers.txt
│   ├── top_sms_senders.txt
│   ├── unified_timeline.txt
│   ├── whatsapp_messages.txt
│   └── whatsapp_urls.txt
├── installed_apps.txt
└── evidence_hashes.txt
```

###Notes
```

If any database or file is missing, the script will skip the corresponding extraction and show a warning.

WhatsApp messages are optional and require the msgstore.db file in /data/data/com.whatsapp/databases/.

Chrome history extraction works only if the user data exists in the mounted image.

Ensure proper permissions when accessing the mounted Android image.

Example
Enter Case ID: 1234
Enter mounted Android image path: /mnt/android_image


The script will create:

android_forensics_1234_2025-12-23_150005/


Inside the folder, you will find CSVs, reports, statistics, and timelines ready for forensic analysis.
```

Disclaimer

This tool is intended for educational and authorized forensic purposes only. Unauthorized access to devices or personal data may violate laws and regulations.
