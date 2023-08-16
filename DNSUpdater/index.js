const execSync = require('node:child_process').execSync;
const fs = require('node:fs');
const check_internet = require('./check_internet');
const updateCloudflare = require('./cloudflare');

//Variables
const Path = "/root/DNSUpdater" //ENTER HERE FULL PATH e.g. /home/pi/DNSUpdater
const MAIL_SERVER = "ENTER YOUR MAIL SERVER HERE" //e.g. smtp.gmail.com
const MAIL_USER = "ENTER YOUR MAIL USER HERE" //e.g. user@gmailcom
const MAIL_PASS = "ENTER YOUR MAIL PASSWORD HERE" //e.g. password
const MAIL_FROM = "ENTER YOUR MAIL FROM HERE" //e.g. user@gmailcom
const MAIL_TO = "ENTER YOUR MAIL TO HERE" //e.g. user@gmailcom
const MAIL_CC = ["ENTER YOUR MAIL CC HERE"] //e.g. user@gmailcom
const MAIL_SUBJ = "IP Changed" //EMail Subject

function log(message, log_file = "cloudflare") {
    fs.appendFileSync(`${Path}/logs/${log_file}.log`, `[${new Date().toISOString()}] - ${message}\n`);
}

let ip1 = ""
let ip2 = ""
let localip = execSync('ip addr show eth0 | grep \'inet\' | awk \'{print $2}\' | cut -f1 -d\'/\' | head -n 1');
( async () => {
    ip1 = fs.readFileSync(`${Path}/ip.txt`, 'utf8');
    ip2 = await ( await fetch('https://ip4only.me/ip/' ) ).text();
    let rip = ip2
    log("IP Checker script is running")

    if (ip2 === "") {
        log("Error fetching remote IP", "error");
        log(`Local IP: ${localip} - Remote IP: ${rip}`, "iphistory");
        check_internet(Path);
    } else if (ip1 == ip2) {
        log(`Local IP: ${localip} - Remote IP: ${rip}`, "iphistory");
        check_internet(Path);
    } else {
        fs.writeFileSync(`${Path}/ip.txt`, ip2);
        log(`IP seems to have changed from ${ip1} to ${ip2}`);
        log(`Local IP: ${localip} - Remote IP: ${rip}`, "iphistory");
        check_internet(Path);
        await updateCloudflare(Path, rip);

        const nodemailer = require('nodemailer');
        const transporter = nodemailer.createTransport({
            host: MAIL_SERVER,
            port: 465,
            secure: true,
            auth: {
                user: MAIL_USER,
                pass: MAIL_PASS
            }
        });

        transporter.sendMail({
            from: MAIL_FROM,
            to: MAIL_TO,
            subject: MAIL_SUBJ,
            text: `This is an automated message from the RaspberryPi DNSUpdater for CloudFlare script. The IP has been changed to ${ip2}`,
            cc: MAIL_CC
        }, (err, info) => {
            if (err) {
                log(`Error sending email. Check error log file for full analysis`);
                log(`Error sending email: ${err}`, "error");
            } else {
                log(`Email sent: ${info.response}`);
            }
        });

    }
} )();