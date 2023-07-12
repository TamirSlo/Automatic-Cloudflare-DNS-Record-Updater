const fs = require('node:fs');

// Change these
const AUTH_EMAIL = ""; // Cloudflare email address
const AUTH_KEY = ""; // Cloudflare API key

const api = require('cloudflare')({
    email: AUTH_EMAIL,
    key: AUTH_KEY
});

function log(path, message, log_file = "cloudflare") {
    fs.appendFileSync(`${path}/logs/${log_file}.log`, `[${new Date().toISOString()}] - ${message}\n`);
}

async function updateCloudflare(path, newIP) {
    try {
        const zones = await api.zones.browse()


        for (let i = 0; i < zones.result.length; i++) {
            const zone = zones.result[i];

            try {
                const dns_records = await api.dnsRecords.browse(zone.id)

                for (let j = 0; j < dns_records.result.length; j++) {
                    const record = dns_records.result[j];

                    if (record.type !== "A") continue;
                    if (record.proxied !== true) continue;

                    if (record.content === newIP) {
                        log(path, `IP ${newIP} is already set for ${record.name}`);
                        continue;
                    }

                    try {
                        await api.dnsRecords.edit(zone.id, record.id, {
                            type: record.type,
                            name: record.name,
                            content: newIP,
                            proxied: record.proxied
                        })
                        log(path, `${record.name}: Updated dns to ${newIP}`);
                    } catch (e) {
                        log(path, `${record.name}: Error updating dns to ${newIP}`);
                        log(path, `Error Updating DNS. ZoneID: ${zone.id}. RecordID: ${record.id}. Record Name: ${record.name}. Record Content: ${record.content}. ${JSON.stringify(e)}`, "error");
                    }
                }
            } catch (e) {
                log(path, "Records query was NOT successful, please check error log file for full analysis");
                log(path, JSON.stringify(e), "error");
            }
        }
    } catch (e) {
        log(path, "Zones query NOT successful, please see Error log file for full analysis");
        log(path, JSON.stringify(e), "error");
    }
}

module.exports = updateCloudflare;