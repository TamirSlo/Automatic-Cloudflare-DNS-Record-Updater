# Automatic-Cloudflare-DNS-Record-Updater
With this simple script you can automatically update your router's IP for all/some zones on your Cloudflare account.
Simply copy the "DNSUpdater" folder onto your linux based computer and make sure the config file is edited appropriatley!
Then add a cron job with a link to the '..path..'\DNSUpdater\main.sh and execute it automatically. The script will check for any changes to your IP address and will notify you by email or with our soon to be cPanel-like domain manager service for ARM based computers!
