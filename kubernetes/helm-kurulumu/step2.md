# Kurulum Dosyalarının indirilmesi

Helm kurulumu için gerekli dosyalar github üzerinde yer almaktadır. Kurulum için kullanılacak güncel sürüm aşağıdaki komutla öğrenilebilir;

`curl --silent "https://api.github.com/repos/helm/helm/releases" | grep -Po '"tag_name": "\Kv2\..*?(?=")' | head -1`{{execute}}

İlerleyen kurulum adımlarında bu değeri kullanmak üzere aşağıdaki komutla **HELM_RELEASE** değişkeninde saklayın;

`export HELM_RELEASE=$(curl --silent "https://api.github.com/repos/helm/helm/releases" | grep -Po '"tag_name": "\Kv2\..*?(?=")' | head -1)`{{execute}}

## Kurulum Dosyalarının İndirilmesi

Güncel sürümün tespit ettikten sonra aşağıdaki komut yardımıyla gerekli dosyalar yerele indirilir;

`curl https://get.helm.sh/helm-$HELM_RELEASE-linux-amd64.tar.gz -o helm-$HELM_RELEASE-linux-amd64.tar.gz`{{execute}}

indirilen sıkıştırılmış dosyayı aşağıdaki komutla ayıklayın;

`tar -zxvf helm-$HELM_RELEASE-linux-amd64.tar.gz`{{execute}}

Gerekli dosyalar artık yerelimizde. **Continue** butonuna basarak sıradaki adıma geçebilirsiniz.
