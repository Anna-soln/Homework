#!/bin/bash
#Task 1
#в переменную читаем значение из командной строки( имя файла)
file_form="$1"

#Проверяем существует ли файл
if [ ! -f "$file_form" ]; then
  echo "Ошибка: файл не найден"
fi

#Проверяем формат файла
#Используем case, т.к. даны два условия
case "$file_form" in
  *.csv) del=',' ;;
  *.tsv) del=$'\t' ;;
  *) echo "Ошибка.Файл не соответсвует ни CSV, ни TSV - форматам"; exit 1 ;;
esac

#Проверяем, что файл не пустой
if [ ! -s "$file_form" ]; then
  echo "Ошибка. Файл пустой"
  exit 1
fi

cat "$1"

#Читаем файл построчно и сравниваем количесвто столбцов в строке
etalon1=0
line_num=0
bad=0
while IFS= read -r line || [ -n "$line" ];do
  line_num=$((line_num + 1))
  del_count=0
  tmp="${line//$del/}"
  del_count=$(( ${#line} - ${#tmp} ))
  etalon1=$((del_count+1))
#если строка первая, тогда в etalon записываем значение etalon1
  if [[ "$line_num" -eq 1 ]]; then
    etalon=$etalon1
   echo "Ожидаемое число столбцов в каждой строке: " $etalon
  elif [ "$etalon1" -ne "$etalon" ]; then
   echo "Файл некорректен. Строка" $line_num "содержит" $etalon1 "столбцов, ожидалось" $etalon
   bad=1
  fi
#условие, что файл закончился
done < "$file_form"
if  [ "$bad" -eq 0 ]; then
  echo "Файл корректен.Файл содержит" $line_num "строк и" $etalon "столбцов"
else
  echo "Файл не корректен.Число столбцов в строках разное"
fi
echo "Проверка завершена."

#Task 2
#Существует ли файл или директория
if [ ! -e "$TARGET" ]; then
  echo "Ошибка: не существует: $TARGET"
  exit 2
fi

data=17.10.2026
#Условия на директорию или файл
if [ -d "$TARGET" ]; then
  echo "Это директория. Вложения: "
  ls -l "$TARGET"
  for f in "$TARGET"/*.txt; do
   [ -f "$f" ] || continue
   echo "Это .txt файл"
   copy_file="${f%.txt}_${data}.txt"
   cp -- "$f" "$copy_file"
   echo "  -> копия: $copy_file"
  done
  echo "Результаты изменений: "
  ls -l "$TARGET"
else
  echo "Ошибка:это не дериктория."
fi


#Task3
if [ -e "$file_1" ]; then
    echo "Использование: $0 <файл.txt>"
    exit 1
fi

#Проверка существует ли файл
if [ ! -f "$file_1" ]; then
    echo "Ошибка: файл не найден: $file_1"
    exit 1
fi
#Проверка что файл не пустой
if [ ! -s "$file" ]; then
    echo "Ошибка: файл пустой"
    exit 1
fi

tr -cs '[:alpha:]' '\n' < "$file" \
    | tr '[:upper:]' '[:lower:]' \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -n 10

#Task4

#Проверяем что программа работает без ошибок и случайных значений
set -euo pipefail
export LC_ALL=C

if (( $# != 0 )); then
    printf 'Использование: bash %s\n' "$0" >&2
    exit 1
fi

#сохраняем путь до файла со скриптом
script_path=${BASH_SOURCE[0]}
#Начальная директория
directory=.
# Проверяем существуют ли поддиректории и удаляем все части пути с предыдущим символом /
if [[ "$script_path" == */* ]]; then
   directory=${script_path%/*}
fi

#Сохраняем в переменную абсолютный путь к информации в исследуемой дирректории
directory=$(cd -- "$directory" && pwd)

#Получаем список с информацией о файлах в директории
#Для удобства убираем скрытые символы, цветовые коды и время создания файла
listing=$(ls -lAnb --block-size=1 --time-style=+ --color=never -- "$directory")

# с помощью grep выбираем только обычные файлы из полученного списка
files=$(printf '%s\n' "$listing" | grep '^-' || [[ $? == 1 ]])

#Счётчики для интересующей нас директории. Общий объём файлов и их число.
declare -A counts=()
total_files=0
total_size=0

# с помощью цикла анализируем список, пропускаем пустые записи, если список файлов пуст
while read -r permissions links owner group size name; do
    [[ -n "$permissions" ]] || continue
    extension=${name#.}
    type='[без расширения]'
#если название файла срдержит точку, то отрезаем всё до точки, оставляя только формат.
#Проверка, что имя файла не заканчивается точкой
    if [[ "$extension" == *.* && "$extension" != *. ]]; then
#Удаление одной точки в начале имени, чтобы формат читался однозначно.
        extension=${extension##*.}
#Задаём нужный (нижий) регистр и добавляем точку для формата txt
        type=".${extension,,}"
    fi
#счётчики для каждого txt файла и общего числа файлов и их размера
    counts["$type"]=$(( ${counts["$type"]:-0} + 1 ))
    total_files=$((total_files + 1))
    total_size=$((total_size + size))
done <<< "$files"

#Вывод информации по каждому типу файла
printf 'Количество файлов по типам:\n'
for type in "${!counts[@]}"; do
    printf '%s: %d\n' "$type" "${counts["$type"]}"
done
#Вывод общей информации по всем файлам директории
printf 'Всего файлов: %d\n' "$total_files"
printf 'Общий размер: %d байт\n' "$total_size"


#Task5

#в переменную читаем значение из командной строки( имя файла)
file_tab="$1"

#Проверяем существует ли файл
if [ ! -f "$file_tab" ]; then
  echo "Ошибка: файл не найден"
  exit 1
fi

#Проверяем, что файл не пустой
if [ ! -s "$file_tab" ]; then
  echo "Ошибка. Файл пустой"
  exit 2
fi

while IFS= read -r line || [ -n "$line" ]; do
  IFS=',' read -r student predmet mark_1 <<< "$line"
  [[ "$mark_1" =~ ^[0-9]+$ ]] || continue
  if [[ "$mark_1" -ge 3 ]]; then
   printf '%s\t%s\t%d\n' "$student" "$predmet" "$mark_1"
  fi
done < "$file_tab" | sort -t$'\t' -k1,1 -k3,3nr


#Task 6
#Список хостов
hosts=("8.8.8.8" "1.1.1.1" "ya.ru" "google.com" "no-such-host.local")

#Счётчики успешного и неуспешного пинга
ok=0
fail=0
#Пинг каждого хоста из спсика
for h in "${hosts[@]}"; do
    if ping -c 1 -W 2 "$h" > /dev/null 2>&1; then
        echo "[ OK ] $h"
        ok=$((ok + 1))
    else
        echo "[FAIL] $h"
        fail=$((fail + 1))
    fi
done

echo "Доступно: $ok, недоступно: $fail"


#Task 7

echo "Введите число: "
read -r count
echo "Обратный отсчёт начался: "
echo ""
for i in $(seq "$count" -1 0); do
  if [ "$count" -ge 0 ]; then
    printf  '%*s\n' "$i" '' | tr ' ' '*'
    sleep 0.4
  else
    exit 1
  fi
done
echo "Поехали!"
