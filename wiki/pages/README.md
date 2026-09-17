# Wiki proposal — Vehicle updates (RU/EN)

Эти файлы — готовое обновление для https://github.com/Karpenator/SG-Traders-WIKI
под последние фичи ветки `arena/01a0aabd-syndicate-project`:

* `VehicleAttachments` на каждом `Items` / `Barters` — полный набор навесов для транспорта
  (`Class:Qty`, пусто = старый авто-набор, непусто = полностью заменяет)
* `VehicleSpawnPosition` / `VehicleSpawnOrientation` / `VehicleSpawnRadius` на торговце
* Ячейка транспорта 256×128, предпросмотр с навесами, 10% топливо
* 7 ванильных машин у Механика из коробки (424 товара вместо 417, всего 1981)

Файлы уже лежат в формате `wiki/pages/` — скопируйте их в клон вики и запустите публикацию.

## Как опубликовать (у владельца вики)

```bash
git clone https://github.com/Karpenator/SG-Traders-WIKI.git
cp wiki-proposal/EN-Trader-File.md        SG-Traders-WIKI/wiki/pages/
cp wiki-proposal/EN-Items-And-Barters.md   SG-Traders-WIKI/wiki/pages/
cp wiki-proposal/RU-Файл-торговца.md       SG-Traders-WIKI/wiki/pages/
cp wiki-proposal/RU-Товары-и-бартеры.md    SG-Traders-WIKI/wiki/pages/
cd SG-Traders-WIKI/wiki
./publish-wiki.sh   # или .\publish-wiki.ps1 на Windows
```

Альтернативно — примените патч `wiki-vehicle-docs.patch`:

```bash
cd SG-Traders-WIKI
git apply ../wiki-proposal/wiki-vehicle-docs.patch
git add wiki/pages/*.md
git commit -m "docs: vehicle bay + VehicleAttachments"
git push
cd wiki && ./publish-wiki.sh
```

Сэндбокс Arena не имеет прав на push в `Karpenator/SG-Traders-WIKI` напрямую
(`403 Resource not accessible by integration` для `arena-ai-coding-agent[bot]`),
поэтому публикацию должен сделать владелец репозитория.
