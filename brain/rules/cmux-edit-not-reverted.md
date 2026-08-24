# cmux system-reminders після Edit — НЕ реверс

## Проблема
Після кожного Edit tool cmux показує system-reminder "Note: file was modified, either by the user or by a linter" зі СТАРИМ вмістом файлу. Агенти думають що Edit реверснувся і починають переписувати файли через Write/sed — зайва робота.

## Причина
cmux інжектить async PreToolUse hook (`cmux hooks claude pre-tool-use`) який зчитує файл ПАРАЛЕЛЬНО з Edit. System-reminder прилітає ПІСЛЯ Edit, але показує контент ДО Edit.

## Правило
- **НЕ переписувати** файл через Write/sed після Edit якщо прийшов такий system-reminder
- **НЕ перевіряти** git diff для підтвердження — Edit працює коректно
- Єдиний виняток — якщо build/typecheck покаже реальну помилку
- Це стосується ВСІХ проєктів де використовується cmux
