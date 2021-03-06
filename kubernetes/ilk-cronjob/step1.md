# Lab Ortamı

Sizin için 1 master, 1 worker node olarak yapılandırılmış şekilde bir Kubernetes Cluster'ı kuruludur. Sağ bölümde kurulu olan bu Kubernetes Cluster'ının `master` node'u terminalini bulabilirsiniz. Bu terminal üzerinden aşağıda ve takip eden adımlarda detayı verilen senaryoyu deneyimleyebilirsiniz. Senaryo çerçevesinde ihtiyaç duyabileceğiniz araçlar yapılandırılmıştır.

Örneğin aşağıdaki komutla Kubernetes Cluster'ı hakkında bilgi alabilirsiniz;

`kubectl cluster-info`{{execute}}

aşağıdaki komutla Kubernetes Cluster'ına dahil node'ları listeleyebilirsiniz;

`kubectl get nodes`{{execute}}

## CronJob

Aşağıdaki komut çalıştırılarak ilk cronjob tanımı gerçekleştirilir;

```bash
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: ilk-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: ilk-cronjob-konteyner
            image: busybox
            command: ["echo", "İlk zamanlanmış iş çalışıyor.."]
          restartPolicy: OnFailure
EOF
```{{execute}}

Aşağıdaki komutla 3 dakika boyunca cronjob tarafından oluşturulan job’lar izlenir;

`kubectl get jobs -w`{{execute}}

Aşağıdaki komut çalıştırılarak Job hakkında bilgi alınır;

`kubectl describe cronjob ilk-cronjob`{{execute}}

Komut çıktısında yer alan bilgiler incelenir.

Job tarafından oluşturulan pod’ları listelemek için aşağıdaki komut çalıştırılır;

`kubectl get pods`{{execute}}

Aşağıdaki komutla cronjob tanımı silinir;

`kubectl delete cronjob ilk-cronjob`{{execute}}
