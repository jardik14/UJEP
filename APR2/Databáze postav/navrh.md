# Databáze postav

## Atributy postav

časové určení:
    rok
    měsíc?
    týden?
    den v týdnu?

* jméno
* prezdivka
* datum narození
* datum úmrtí (nepovinné)
* události [seznam]
  * start: datum
  * konec: datum
  * popisek
  * lokace

### Operace. které se hodí:
* průřez aktivit postav vnějakém čase či intervalu

## Perzistentní uložiště
* serializace do JSONu
* JSON soubor: pole objektů

## Uživatelské rozhraní
* skript
* něco lepšího