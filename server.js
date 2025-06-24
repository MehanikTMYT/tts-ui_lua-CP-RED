const express = require('express');
const bodyParser = require('body-parser');
const { XMLParser } = require('fast-xml-parser');

const app = express();

// Поддержка JSON и raw текста
app.use(bodyParser.json({ limit: '5mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '5mb' }));

app.post('/api/parse', (req, res) => {
    let xmlString;

    // Случай 1: обычный JSON с полем xml
    if (typeof req.body.xml === 'string') {
        console.log("trim1")
        xmlString = req.body.xml.trim();
    
    // Случай 2: TTS присылает JSON как строку в виде ключа
    } else if (typeof req.body === 'object' && Object.keys(req.body).length === 1) {
        const key = Object.keys(req.body)[0];
        try {
            const parsedKey = JSON.parse(key);
            
            
                xmlString = parsedKey.xml.trim();
            
        } catch (e) {
            // не JSON — возможно, это просто строка
        }
    }

    // Случай 3: если всё ещё не нашли — проверяем, не пришёл ли чистый XML как строка
    if (!xmlString && typeof req.body === 'string') {
        console.log("trim")
        xmlString = req.body.trim();
    }

    // Проверка, что XML найден
    if (!xmlString) {
        return res.status(400).json({ error: 'XML данные отсутствуют в запросе' });
    }

    // Парсим XML
    try {
        const options = {
            ignoreAttributes: false,
            attributeNamePrefix: '@_'
        };

        const parser = new XMLParser(options);
        const parsedXml = parser.parse(xmlString);

        // Словарь для хранения характеристик
        const stats = {};

        // Рекурсивная функция поиска нужных InputField
        function findStatFields(obj) {
            if (typeof obj !== 'object' || obj === null) return;

            for (let key in obj) {
                const value = obj[key];

                if (
                    typeof value === 'object' &&
                    value['@_id'] &&
                    value['@_id'].endsWith('_stat') &&
                    value['@_text']
                ) {
                    const match = value['@_text'].match(/\{([^}]*)\}/);
                    if (match && match[1]) {
                        stats[value['@_id']] = match[1];
                    }
                }

                findStatFields(value);
            }
        }

        findStatFields(parsedXml);
        console.log(stats);
        res.json(stats);
    } catch (err) {
        console.error('Ошибка парсинга XML:', err.message);
        res.status(500).json({ error: 'Ошибка парсинга XML' });
    }
});

app.post('/api/npc', (req, res) => {
    let charName;

    // Пытаемся получить имя из разных форматов тела запроса
    if (typeof req.body === 'string') {
        charName = req.body.trim();
    } else if (typeof req.body.name === 'string') {
        charName = req.body.name.trim();
    } else {
        return res.status(400).json({ error: 'Имя персонажа отсутствует' });
    }

    console.log(`Получено имя NPC: ${charName}`);

    // Ответ — временно просто строка
    res.json({ message: `Здравствуйте, ${charName}!` });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`✅ Сервер запущен: http://localhost:${PORT}`);
});