# Tek Komutluk Script ile Celestia Light Node Çalıştırmak

<img src="https://i.ytimg.com/vi/9uL3jZe4mTY/maxresdefault.jpg" width="700"/>

## Celestia Hakkında
Celestia, kullanıcı sayısıyla güvenli bir şekilde ölçeklenen, modüler bir veri kullanılabilirliği ağıdır ve herkesin kendi blok zincirini kolayca başlatmasını sağlar.
* [Twitter](https://x.com/CelestiaOrg)
* [Website](https://celestia.org/)
* [Discord](https://discord.com/invite/YsnTPcSfWQ)
* [Docs](https://docs.celestia.org/)
* [Github](https://github.com/celestiaorg)

#### Bu script, tek bir komutla `Celestia Light Node`'unu kurup çalıştırmanızı sağlar. Script, gerekli kurulumları otomatik olarak yapar, Light node'u kurar ve screen içinde çalıştırır.


## Sistem Gereksinimleri

- Memory: 500 MB RAM (minimum)
- CPU: Single Core
- Disk: 100 GB SSD Storage
- Bandwidth: 56 Kbps for Download/56 Kbps for Upload

## Light Node Hakkında
Light nodelar, herhangi bir merkezi ağ geçidi veya RPC sağlayıcısı olmadan veri kullanılabilirliğini doğrudan doğrulamanıza ve Celestia ile etkileşim kurmanıza olanak tanır. Alınan başlıklar üzerinde data availability sampling (DAS) gerçekleştirirler, bu da veri kullanılabilirliğini sağlar. Bu, Celestia ağlarıyla etkileşim kurmanın en yaygın yoludur ve zamanla ağa katılan yeni light node'lar sayesinde Celestia'nın rolluplar için güvenli bir şekilde throughput'u artırmasını sağlar.

<div style="text-align: center;">
    <img src="https://docs.celestia.org/img/nodes/LightNodes.png" width="700"/>
</div>

## Nasıl Kullanılır?

Bu script'i kullanmak için terminalinize aşağıdaki komutu girin:
```bash
wget -q -O kocality.sh https://raw.githubusercontent.com/kocality/celestia-light/main/kocality.sh && sudo chmod +x kocality.sh && ./kocality.sh
```

Not: Screen'den `CTRL A+D` ile çıkabilirsiniz. Bu şekilde çıktığınızda node`unuz screen'de çalışmaya devam edecektir. 

### LM🦥
