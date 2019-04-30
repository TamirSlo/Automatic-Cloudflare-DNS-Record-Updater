# Automatic-Cloudflare-DNS-Record-Updater
With this simple script you can automatically update your router's IP for all/some zones on your Cloudflare account.
Simply copy the "DNSUpdater" folder onto your linux based computer and make sure the config file is edited appropriatley!
Then add a cron job with a link to the '..path..'\DNSUpdater\main.sh and execute it automatically. The script will check for any changes to your IP address and will notify you by email or with our soon to be cPanel-like domain manager service for ARM based computers!

## How to install?
1. Simply downlaod the files and make sure to change the Path variable at the start of main.sh
2. Ensure the Logs folder is created as 'logs' (Manual Process) as shown in the file structure.
3. Write down your Cloudflare EMail and API Key inside cloudflare.sh
4. Add a cron job:
  - In shell type in the following command: `crontab -e`
  - Then add the following line: `*/15 * * * * bash /home/pi/DNSUpdater/main.sh` and the script will be executed every 15 minutes.
  - Make sure you change the path in the above line to fit your case.
  
_Any feedback will be appreciated using the Contact Form within **[my Website](https://tamirslodev.tk/)**_
