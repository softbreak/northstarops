# Claim Süresi Dolarsa Ne Olur?

Bir Issue'yu claim ettikten sonra **24 saat içinde** ilgili Issue'ya bağlı bir Draft Pull Request açman gerekir.

Bu süre içinde uygun Draft PR açılmazsa claim otomatik olarak düşer.

## Claim düştüğünde

- Issue üzerindeki assignee kaldırılır.
- `status: claimed` kaldırılır.
- `status: available` yeniden eklenir.
- Issue başka bir katılımcı tarafından claim edilebilir.
- Issue altında claim süresinin dolduğunu açıklayan bir bilgilendirme mesajı gösterilir.

## Çalışmaya devam etmek istiyorsan

Issue hâlâ `status: available` ise yeniden `/claim` yazabilirsin. Ancak bu sırada başka bir katılımcı Issue'yu claim etmiş olabilir.

## Önemli

Yerel branch oluşturmuş veya kod yazmış olman claim'i aktif tutmaz. Süreyi karşılayan şey, ilgili Issue'ya bağlı Draft Pull Request'in zamanında açılmış olmasıdır.