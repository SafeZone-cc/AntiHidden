# AntiHidden

Программа для удаления последствий действия вредоносного ПО на съемном накопителе.

Разработчик: Польшин Станислав.

В программе использована служба [USBDLM](http://www.uwe-sieber.de/usbdlm_e.html) от Uwe Sieber.

## Назначение

- Если Ваша флешка побывала на компьютере с вирусом, скрывающим папки, а вместо них - теперь ярлыки.
- Вы хотите, чтобы на флешке физически нельзя было создать autorun.inf, который дает команду на автозапуск паразитов.
- Вся информация с флешки перемещена вирусом в папку с "пробелом".

Тогда эта программа для Вас.

Программа устанавливается на компьютер в виде сервиса.
Каждый раз, когда Вы подключаете к ПК флешку, происходит ее лечение.

![antihidden](https://user-images.githubusercontent.com/19956568/43048216-a97b3ffa-8dec-11e8-973c-aa57c6db003f.png)

## Установка и  использование

**Вариант А** - без установки:
1. Скопируйте файл _Anti_Hidden Удаление последствий вредоносного ПО на флешке.cmd на флешку
и запускайте его с флешки.

**Вариант Б** - с установкой (программа будет автоматически запускаться при каждом подключении флешки):

1. Распакуйте архив Anti_Hidden.zip
2. Запустите установщик **Установка-удаление AntiHidden.vbs**

При желании Вы можете отключить автозапуск со все съемных накопителей, кроме CD-ROM.
Программа спросит Вас об этом.

Если Вам не нужно каждый раз открывать окно проводника по завершении сканирования,
зайдите в меню "ПУСК", "Все программы", "AntiHidden"
и выберите пункт "Не открывать проводник после лечения флешки".

## Удаление
Через Меню ПУСК -> AntiHidden
Или через оригинальный установщик "Установить AntiHidden.vbs".

## Описание работы

- Удаление файлов с расширением *.lnk (ярлыки), имя которых соответствует имени папки.
- Снятие атрибутов "скрытый", "системный" с папок в корне флешки.
- Перенос информации из "невидимой папки" (папки с символом 0xA0) в корень флешки (при совпадении имен файлы не заменяются, а дописываются цифры в скобках).
- Удаление файла автозапуска "autorun.inf".
- Создание папки "autorun.inf" (контр-мера против дальнейшей возможности создавать файл autorun.inf)
- Удаление модифицированных системных папок "recycled", "recycler", "System Volume Information" из корня флешки.
- Удаление дополнительных обычно вспомогательных вредоносных файлов (System, Game.cpl), а также desktop.ini, Thumbs.db и *.init
- Переименование файлов *.LNK в *.LNK_

## Лицензионное соглашение

Программа AntiHidden может быть использована свободно в личных некоммерческих или образовательных целях.
Перепубликация на другие ресурсы без разрешения автора запрещена.

Модификация кода запрещается.

С лицензией на программу USBDLM, вместе с которой работает AntiHidden, можно ознакомится по этой ссылке: [USB Drive Letter Manager - USBDLM](http://www.uwe-sieber.de/usbdlm_e.html)
