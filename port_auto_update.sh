#!/bin/bash
set -e  # 脚本执行出错时自动退出

if [ $# -lt 1 ]; then
  echo "No host name"
  exit 1
fi

# 配置项
CONFIG_FILE="/usr/local/etc/v2ray/config.json"
RANDOM_PORT_RANGE="15300-20000"
HOST_NAME=$1

# 生成随机端口（15300~20000）
NEW_PORT=$(shuf -i $RANDOM_PORT_RANGE -n 1)
echo "New Port: $NEW_PORT"

# 更新 v2ray 配置文件中的端口
sudo jq --arg new_port "$NEW_PORT" '.inbounds[0].port = ($new_port | tonumber)' $CONFIG_FILE > tmp.json && sudo mv tmp.json $CONFIG_FILE

# 重启 v2ray 服务
sudo systemctl restart v2ray
echo "V2Ray restarted with new port: $NEW_PORT"

# 开始更新订阅
cd /root/server_subscription

# 生成vmess订阅地址
python generate_vmess.py $HOST_NAME > $HOST_NAME

# 更新git
git pull
git add -A
git commit -m "$HOST_NAME auto update: $(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')"
git push

# 等待git更新完成后，强制更新cdn
sleep 30
https://purge.jsdelivr.net/gh/rehtal-work/server_subscription@master/$HOST_NAME
