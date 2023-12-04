# Установка CryptoPro CSP

## Установка из дистрибутива

Дистрибутив находится в директории `cryptopro-pkg` данного проекта. Для установки дистрибутива необходимо
извлечь содержимое архива и выполнить скрипт `install.sh` от имени суперпользователя:

```bash
cd cryptopro-pkg
tar xzvf linux-amd64_deb.tgz
cd linux-amd64_deb
sudo bash ./install.sh lsb-cprocsp-devel

# Также необходимо установить cades-плагин
cd ..
sudo dpkg -i ./cprocsp-pki-cades_2.0.0-1_amd64.deb
```

## Настройка
### Провайдер по умолчанию
После установки имеет смысл сразу выбрать `Crypto-Pro GOST R 34.10-2012 KC1 CSP` в качестве провайдера по умолчанию:

```bash
sudo /opt/cprocsp/sbin/amd64/cpconfig -defprov -setdef -provtype 80 -provname 'Crypto-Pro GOST R 34.10-2012 KC1 CSP'
```

### Настройка ГСЧ
Чтобы обеспечить автономность выполнения тестов можно настроить криптопро на использование внешней гаммы вместо
биалогического ГСЧ. Гамму можно клонировать из образца, расположенного в `cryptopro-pkg/kis_1` (⚠️ данный сценарий
подходит для тестов во временном тестовом окружении, в других окружениях должен использоваться сертифицированный
физический ГСЧ):

```bash
# Директории для будущей гаммы
mkdir -p db1
mkdir -p db2

# Клонируем гамму много раз
for x in {1..100}
    do cat path/to/kis_1 >> db1/kis_1
done

# Клонируем результат еще много раз
for x in {1..1000}
    do cat db1/kis_1 >> db2/kis_1
done

# Используем самый большой результат
cp db2/kis_1 db1/kis_1

#
# Настраиваем КриптоПро на использование нашей гаммы.
#

# 1. Создаем ГСЧ
sudo /opt/cprocsp/sbin/amd64/cpconfig -hardware rndm -add cpsd -name 'cpsd rng' -level 3

# 2. Настраиваем первую гамму
sudo /opt/cprocsp/sbin/amd64/cpconfig \
    -hardware rndm -configure cpsd \
    -add string \
    `# Это внутренний путь криптопровайдера и он должен быть именно таким`
    /db1/kis_1 /path/to/db1/kis_1 \
    `# Это гамма, которую мы сгенерировали ниже`
    path/to/db1/kis_1

# 3. Настраиваем вторую гамму
sudo /opt/cprocsp/sbin/amd64/cpconfig \
    -hardware rndm -configure cpsd \
    -add string \
    `# Это внутренний путь криптопровайдера и он должен быть именно таким` \
    /db2/kis_1 \
    `# Это гамма, которую мы сгенерировали ниже` \
    /path/to/db2/kis_1

# Проверяем работу гаммы (первый запуск может вывести ошибку).
# Результатом должна быть успешная генерация ключа без запросов на ввод символов с клавиатуры
/opt/cprocsp/bin/amd64/csptest -keyset -newkeyset -machinekeyset -password 123456 -hard_rng -container 'HDIMAGE\\dummy'
```

### Логирование
При разработе может оказаться полезно логирование, встроенное в различные модули КриптоПро. Включить полное логирование
для модулей можно следующими командами:

```bash
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel ocsp -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel tsp -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cades -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cpcsp -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capi10 -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cprdr -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cpext -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capi20 -mask 0xF
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capilite -mask 0xF
```
### delete all logs
```bash
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel ocsp -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel tsp -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cades -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cpcsp -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capi10 -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cprdr -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel cpext -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capi20 -mask 0
sudo /opt/cprocsp/sbin/amd64/cpconfig -loglevel capilite -mask 0
```


После настройки логи будут записываться в системный лог, начать просмотр которого можно командой:

```bash
tail -f /var/log/syslog
```

### Настройка окружения и пути к заголовочным файлам
Для сборки проектов, использующих КриптоПро CSP необходимо настроить окружение:

```bash
# Необходимо добавить путь к динамическим библиотекам КриптоПро в текущее окружение
export LD_LIBRARY_PATH=/opt/cprocsp/lib/amd64
```

Также при компиляции необходимо указывать следующие пути к заголовочным файлам (если применимо в вашем случае):

1. `/opt/cprocsp/include`
1. `/opt/cprocsp/include/cpcsp`
1. `/opt/cprocsp/include/asn1c/rtsrc`
1. `/opt/cprocsp/include/asn1data`
1. `/opt/cprocsp/include/pki`

Например в данных биндингах заголовочные файлы используются для автоматической генерации определений функций С-интерфейса КриптоПро CSP. Ключевые заголовки КриптоПро CSP импортируются в файл [`cryptopro_wrapper.h`](exonum-crypto-gost/headers/cryptopro_wrapper.h), который передается в [rust-bindgen](https://github.com/rust-lang/rust-bindgen) для генерации биндингов. Настройка rust-bindgen производится в файле [`gen_cryptopro.rs`](exonum-crypto-gost/gen_cryptopro.rs).

### Установка необходимых сертификатов
Для успешного прохождения всех юнит-тестов, может потребоваться установка корневого сертификата тестового центра КриптоПро:
```bash
/opt/cprocsp/bin/amd64/certmgr -install -store root -f ~/cryptopro-pkg/test_root_ca.cer
```
Также понадобится получить сертификат из тестового центра КриптоПро для создания подписи CAdES-BES:
```bash
/opt/cprocsp/bin/amd64/cryptcp -createcert -rdn 'e=email@test.ru,cn="CryptoPro Test Cert",c=Russia,l="City",o="Test"' -cont '\\.\HDIMAGE\test_cpro'
```