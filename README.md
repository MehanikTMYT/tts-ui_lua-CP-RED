# Character Sheet XML Parser API для Cyberpunk Red в Tabletop Simulator

## Описание
Серверное приложение для автоматического извлечения связей между навыками и характеристиками из XML-интерфейса персонажа Cyberpunk Red в Tabletop Simulator. Сервер парсит XML-структуру UI, находит поля с привязкой к характеристикам (например `{dex}`) и возвращает JSON-ответ с соответствиями вида `"навык_стат": "характеристика"`.

## Технологии
- [Express.js](https://expressjs.com/) - Веб-фреймворк Node.js
- [body-parser](https://www.npmjs.com/package/body-parser) - Парсер тела запросов
- [fast-xml-parser](https://www.npmjs.com/package/fast-xml-parser) - XML-парсер

## Структура проекта
```
.
├── server.js                # Серверный код
├── Pasted_Text_1750793267841.txt  # XML-интерфейс (UI) Cyberpunk Red
├── Pasted_Text_1750793274565.txt  # Lua-скрипт с логикой игры
└── README.md                # Документация
```

## Установка
```bash
npm install express body-parser fast-xml-parser
```

## Запуск
```bash
node server.js
```

Сервер будет доступен по адресу: http://Ваш_адрес:3000/api/parse

## API Документация

### POST /api/parse
**Описание:** Парсит XML и возвращает связи навыков с характеристиками

**Тело запроса:**
```json
{
  "xml": "<Panel>...</Panel>"
}
```

## Формат данных

### XML (Pasted_Text_1750793267841.txt)
Файлы содержат описание UI-элементов:
- **Счетчики характеристик** с фиксированными ID (`int_counter`, `dex_counter`)
- **Поля навыков** с привязкой к характеристикам через `{характеристика}`:
```xml
<InputField id="melee_stat" text="{dex}" />
<InputField id="language_stat" text="{int}" />
```

### Lua (Pasted_Text_1750793274565.txt)
Содержит логику:
- **Цветовые коды характеристик** (hex)
- **Маппинг ID элементов** к характеристикам
- **Обработчики событий** для изменения счетчиков
- **Система бросков кубиков** с критическими успехами/провалами

## Как это работает
1. Сервер получает XML-интерфейс от Tabletop Simulator
2. Находит все `InputField` с атрибутом `id` и значением вида `{характеристика}` к примеру: при обработке персером <InputField id="language_1_stat" fontSize="12" text="{int}" readOnly="true" /> будет связка "language_1":"int"
3. Возвращает JSON с соответствиями ID -> характеристика
4. Lua-скрипт использует эти данные для:
   - Раскраски элементов по цветам характеристик
   - Связи навыков с соответствующими счетчиками
   - Автоматизации бросков кубиков с учетом модификаторов


## Лицензия
MIT License

## Автор
[MehanikTM_YT] — разработчик модификации Cyberpunk Red для Tabletop Simulator

---

## ⚙️ Детали реализации
Сервер использует рекурсивный обход XML-дерева для поиска всех `InputField` с шаблоном:
```javascript
if (value['@_id'] && value['@_id'].endsWith('_stat') && value['@_text']) {
    const match = value['@_text'].match(/\{([^}]*)\}/);
}
```

Lua-скрипт содержит конфигурационные маппинги:
```lua
COUNTER_STAT_MAP = {
    int_counter = "int",
    dex_counter = "dex"
}
```

## 📌 Требования
- Node.js 18+
- Tabletop Simulator (для работы с XML/Lua файлами)
- Установленные пакеты `fast-xml-parser` 

---

Этот парсер позволяет автоматизировать связь между визуальным интерфейсом и игровой логикой, упрощая поддержку сложных таблиц персонажей в Cyberpunk Red.