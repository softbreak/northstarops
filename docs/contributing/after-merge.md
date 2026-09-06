# Merge Sonrası Süreç

Pull Request Squash merge ile `main` branch'e alındığında katkı tamamlanır.

## Sistem tarafında beklenen durum

- İlgili Issue kapanır.
- `status: in-review` kaldırılır.
- `status: done` eklenir.
- Private proje kaydı `Done` durumuna geçer.

## Contributor olarak yapman gereken

Bu Issue için ek işlem yapman gerekmez.

İstersen local çalışma branch'ini silebilir ve fork'unu güncel `main` ile senkronlayabilirsin.

Bir sonraki katkı için yalnızca `status: available` olan Issue'lar arasından yeni bir iş seç ve yeniden `/claim` akışını başlat.

## Teşekkürler

Katkın NorthStarOps'un public GitHub geçmişinin bir parçası oldu. Review ve governance zincirini tamamladığın için teşekkürler.
