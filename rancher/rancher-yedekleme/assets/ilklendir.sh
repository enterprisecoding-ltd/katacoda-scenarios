#!/bin/bash
clear
cat << "EOF"
==================================================================================
   ______       _                       _                        _ _
  |  ____|     | |                     (_)                      | (_)
  | |__   _ __ | |_ ___ _ __ _ __  _ __ _ ___  ___  ___ ___   __| |_ _ __   __ _
  |  __| | '_ \| __/ _ \ '__| '_ \| '__| / __|/ _ \/ __/ _ \ / _` | | '_ \ / _` |
  | |____| | | | ||  __/ |  | |_) | |  | \__ \  __/ (_| (_) | (_| | | | | | (_| |
  |______|_| |_|\__\___|_|  | .__/|_|  |_|___/\___|\___\___/ \__,_|_|_| |_|\__, |
                            | |                                             __/ |
                            |_|                                            |___/
===================================================================================

EOF

if [ $HOSTNAME == "controlplane" ]; then
   MASTER_IP=$(hostname -I | cut -d' ' -f1) 
   echo "Rancher Hazırlanıyor"

   #Rancher şifresi oluştur
   RANCHER_PASS=$(openssl rand -base64 12)
   echo $RANCHER_PASS > /root/rancher_sifresi

   docker run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.5.1 2>/dev/null &> /dev/null
   while true; do curl -sLk https://127.0.0.1/ping && break; printf "."; sleep 2; done

   #Rancher'a giriş yap
   while true; do
      printf "."
      LOGINRESPONSE=$(curl -sk "https://127.0.0.1/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}')
      LOGINTOKEN=$(echo $LOGINRESPONSE | jq -r .token)

      if [ "$LOGINTOKEN" != "null" ]; then
         break
      else
         sleep 5
      fi
   done

   #Varsayılan Rancher şifresini değiştir
   curl -sk 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"'"${RANCHER_PASS}"'"}' 2>/dev/null &> /dev/null

   #API token al
   APIRESPONSE=$(curl -sk 'https://127.0.0.1/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}')
   APITOKEN=`echo $APIRESPONSE | jq -r .token`

   #Rancher sunucu adresini ayarla
   RANCHER_SERVER="https://[[HOST_SUBDOMAIN]]-443-[[KATACODA_HOST]].environments.katacoda.com"
   curl -sk 'https://127.0.0.1/v3/settings/server-url' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"server-url","value":"'"${RANCHER_SERVER}"'"}' 2>/dev/null &> /dev/null
   
   #Telemetriyi kapat
   curl -sk 'https://127.0.0.1/v3/settings/telemetry-opt' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"telemetry-opt","value":"out"}' 2>/dev/null &> /dev/null

   #Firma adını ayarla
   curl -sk 'https://127.0.0.1/v3/settings/ui-pl' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"ui-pl","value":"Enterprisecoding"}' 2>/dev/null &> /dev/null


   # Custer kaydı oluştur
   CLUSTERRESPONSE=`curl -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"dockerRootDir":"/var/lib/docker","enableClusterAlerting":false,"enableClusterMonitoring":false,"enableNetworkPolicy":false,"windowsPreferedCluster":false,"type":"cluster","name":"enterprisecoding-cluster","labels":{}}' --insecure`

   # Docker run komutunu oluşturabilmek için clusterid'yi ayıkla
   CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`

   # Cluster kayıt token'ı oluştur
   curl -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure > /dev/null

   # Master bayrakları
   MASTER_ROLEFLAGS="--etcd --controlplane --worker"

   # Worker bayrakları
   WORKER_ROLEFLAGS="--worker"

   # node komutu oluştur
   AGENTCMD=`curl -s 'https://127.0.0.1/v3/clusterregistrationtoken?id="'$CLUSTERID'"' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --insecure | jq -r '.data[].insecureCommand' | head -1`

   echo ""
   echo "Kubernetes cluster'ı hazırlanıyor..."

   RET=1
   until [ ${RET} -eq 0 ]; do
      kubectl wait --for=condition=ready node node01 2>/dev/null &> /dev/null
      RET=$?
      printf "."
      sleep 2
   done

   echo "$AGENTCMD" > agentcmd.sh
   chmod +x agentcmd.sh
   
   sleep 5
   ./agentcmd.sh 2>/dev/null &> /dev/null

   echo ""
   echo "Rancher kullanıma hazır"
   echo "Kullanıcı Adı: admin"
   echo "Şifre: $(cat /root/rancher_sifresi)"
fi

exec bash