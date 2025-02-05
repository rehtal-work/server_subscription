import json
import sys
import socket
import base64

def extract_ip():
    st = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:       
        st.connect(('10.255.255.255', 1))
        IP = st.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        st.close()
    return IP

config_path = "/usr/local/etc/v2ray/config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

inbound = config['inbounds'][0]
client = inbound['settings']['clients'][0]
stream_settings = inbound['streamSettings']

vmess_data = {
    "v": "2",
    "ps": sys.argv[1],
    "add": extract_ip(),
    "port": inbound['port'],
    "id": client['id'],
    "aid": client.get('alterId', 0),
    "scy": "auto",
    "net": stream_settings['network'],
    "type": "none",
    "host": stream_settings.get('wsSettings', {}).get('headers', {}).get('Host', ''),
    "path": stream_settings.get('wsSettings', {}).get('path', ''),
    "tls": stream_settings.get('security', 'none')
}

vmess_json = json.dumps(vmess_data, separators=(',', ':'))
vmess_link = "vmess://" + base64.b64encode(vmess_json.encode()).decode()
print(vmess_link)
