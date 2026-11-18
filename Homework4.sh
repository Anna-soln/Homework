#!/bin/bash
#Task 1 

#Извлекаем указанные столбцы из файла и сохраняем их в новый файлик
awk '{print $1,$9}' access.log > status_codes.txt

#Меняем значения ошибок с 4** на CLIENR_ERROR
sed -nE '/4[0-9]{2}/ { s/ 4[0-9]{2}/ CLIENT_ERROR/; p; } ' access.log > errors.log

#цикл поиска и и подсчёта обращений для уникальных IP
for IP in $(awk '{print $1}' status_codes.txt | sort -u); do
  count=$(grep -F "$IP" status_codes.txt | wc -l)
  echo "$IP : $count"
done

#Task 2

#Извлекаем указанные столбцы из файла и сохраняем их в новый файли
awk -F, '{print $4 * $5}' products.csv | sort -nr

#Удаляем Stock=0 и сохраняем в другой csv файл
sed -E '/^([^,]*,){4}[[:space:]]*"?0"?[[:space:]]*(,|$)/d' products.csv > available_products.csv

#Цикл поиска товаров, которые стоят больше 100
while IFS= read -r line; do
  case "$line" in
    ID,*) continue ;;
  esac
  printf '%s\n' "$line" | awk -F, '$4 + 0 > 100 { print $2 }'
done < available_products.csv

#Task 3

df -h
echo '------------------------------------'
#Выводим только заданные столбцы и скрываем шапочку(заголовки) столбцов
#Убираем % и меняем dev на device.
#При этом фооматирование будетв ыполнятся для всех столбцов.
#но оидн будет выбиваться из списка из-за изменения длины слова dev
Result= df -h | awk 'NR>1 {printf "%-25s %s\n", $1, $5}' | sed 's/dev/device/g; s/%//g'
IFS=$'\n'
for line in Result;do
  printf ' "%s\n", "$line" ' | awk '$2+0>80 {printf  "Warning: system overload", $1,$2}'
done

#Task 4

# Создаём пары "ключ"="значение"
sed 's/,/\n/g; s/{//g; s/}//g; s/ //g; s/"//g; s/:/=/g' config.json > config.env

#Добавляем к  каждой строке в начало CONF_
awk '{print "CONF_" $0}' config.env > config_res.env

#Экспорт каждой строчки файла как перменных среды
IFS=$'\n'
for line_1 in $(cat config_res.env);do
  export "$line_1" && echo "OK: $line_1" || echo "FAIL: $line_1"
done
unset IFS

#Task 5
#Меняем регистр на нижний и убираем все знаки препинания
tr '[:upper:]' '[:lower:]' < text.txt | sed 's/[^a-z0-9 ]//g' > clean.txt
echo '________CLEAN_FILE______________'
cat clean.txt
#Считаем количество вхождений каждого слова и в отдельном файле выводим 5 наиболее часто встречающихся
awk '{ for (i=1;i<=NF; i++) freq[$i]++ } END {for (w in freq) print w ": " freq[w] }' clean.txt\
 | sort -k2 -nr |head -n 5 > top.txt
cat top.txt
#Словарик
API_URL="https://api.dictionaryapi.dev/api/v2/entries/en"
for word_1 in $(awk -F: 'NR<=5 {print $1}' top.txt); do
  echo " $word_1 "
  definition=$(curl -s "$API_URL/$word_1" \
      | grep -o '"definition":"[^"]*' \
      | head -n 1 \
      | cut -d'"' -f4)
  if [ -n "$definition" ]; then
      echo " $definition"
  else
      echo "   (определение не найдено или произошла ошибка)"
  fi
done

#Task 6

sed -E '/^[^"]*("[^"]*"[^"]*)*"[^"]*$/ s/$/"/' data_1.csv | sed 's/;/,/g;' > data_write.csv

awk -F, 'NF!=3 {print NR ":" $0 }' data_write.csv > bad_lines.csv
cat bad_lines.csv

{ IFS= read -r header
  while IFS= read -r line; do
   [ -z "$line" ] && continue
   printf '%s\n' "$line" | awk -F, ' NF==1 { next }
            NF!=3 { next }
   {
            gsub(/^"|"$/, "", $1)
            gsub(/^"|"$/, "", $2)
            gsub(/^"|"$/, "", $3)
            printf "Hello, my name is %s. I am %s years old and I live in %s.\n", $1, $2, $3 }'
  done
} < data_write.csv > sentences.csv

#Task 7

mkdir my_project
cd my_project
mkdir src docs tests build

cd src
mkdir images scripts data
cd -

cd docs
mkdir images scripts data
cd -

cd tests
mkdir images scripts data
cd -

cd build
mkdir images scripts data
cd -

for d in . \
         src docs tests build \
         {src,docs,tests,build}/{images,scripts,data}; do
    if [ "$d" = "." ]; then
        echo "Создана директория: my_project"
    else
        echo "Создана директория: my_project/$d"
    fi
done

touch README.md

#Task 8

mkdir logs
cd logs

for N in {1..10}; do
  touch "log_$(printf '%02d' $N).txt"
  echo "Это лог номер $N" > "log_$(printf '%02d' $N).txt"
  cat "log_$(printf '%02d' $N).txt"
done

for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        rm -f "log_$(printf '%02d' $i).txt"
    fi
done
ls log_*.txt

#Task 9

touch document1.txt document2.txt document3.txt document4.txt document5.txt
mkdir renamed

ls document*.txt | while IFS= read -r f; do
  echo "Файл: $f"
  mv -v --  "$f" "renamed/$(printf '%s\n' $f| sed 's/^document/file/g')"
done

ls -l renamed/

#Task 10

mkdir backup
mkdir all_backups
for i in {1..7}; do
  dir="backup/day_$i"
  mkdir -p "backup/day_$i"
  mkdir -p "$dir"
  echo "Резервная копия за день $i" > "$dir/info.txt"
  cp -v "backup/day_$i/info.txt" "all_backups/info_day_$i.txt"
done

ls -l all_backups

#Task 11

cd "$(dirname $0)" || exit 1
touch image1.jpg image2.png doc1.txt doc2.pdf script.sh archive.tar.gz
mkdir images documents scripts archives
for f in *; do
    [ -f "$f" ] || continue
    case "$f" in
        *.tar.gz)      dest="archives"  ;;
        *.jpg|*.png)   dest="images"    ;;
        *.txt|*.pdf)   dest="documents" ;;
        *.sh)          dest="scripts"   ;;
        *)             continue         ;;
    esac
    if [[ "$f" == *.* ]]; then
        ext="${f##*.}"
    else
        ext="(нет)"
    fi

    mv -v -- "$f" "$dest/"
done
ls -R images documents scripts archives
