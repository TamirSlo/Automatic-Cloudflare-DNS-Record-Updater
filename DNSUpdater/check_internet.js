const execSync = require('node:child_process').execSync;
const fs = require('node:fs');

function log(path, message, log_file = "cloudflare") {
    fs.appendFileSync(`${path}/logs/${log_file}.log`, `[${new Date().toISOString()}] - ${message}\n`);
}

function check_internet(path) {
    for (let attempt = 0; attempt < 3; attempt++) {
        for (let i = 0; i < 5; i++) {
            const localInternetResult = execSync('ping -q -w1 -c1 google.com &>/dev/null');
            if (localInternetResult) {
                log(path, "Internet is up and running");
                return true;
            } else {
                log(path, "Internet seems to be offline... Trying again.");
            }
        }
        if (attempt === 2) {
            break;
        }
        log(path, "Internet found to be offline. Restarting Network");
        execSync('service networking restart');
    }

    log(path, "Internet connection cannot be restored. Restarting machine.");
    log(path, "Machine restarting - No interent connectivity", "error");
    execSync('reboot');
}

module.exports = check_internet;
