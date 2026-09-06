# PR Onaylandıktan Sonra Ne Olur?

Pull Request reviewer tarafından onaylandığında contributor tarafındaki ana geliştirme işi tamamlanmış olur.

## Bu aşamada

- Yeni bir PR açma.
- Gereksiz ek commit gönderme.
- Review tamamlandıysa mevcut PR'ı olduğu gibi bırak.
- Merge işlemini reviewer/maintainer gerçekleştirir.

NorthStarOps `main` branch koruması nedeniyle merge işlemi PR üzerinden ve yalnızca izin verilen merge yöntemiyle yapılır.

## Merge yöntemi

NorthStarOps katkıları **Squash merge** ile birleştirilir. Böylece katkının ara commitleri `main` geçmişinde tek bir anlamlı commit olarak tutulur.

## Approval merge anlamına gelmez

Approval, PR'ın review açısından kabul edildiğini gösterir. Lifecycle ancak merge tamamlandığında `Done` durumuna geçer.

Merge sonrasında [merge sonrası rehberine](after-merge.md) geçebilirsin.
