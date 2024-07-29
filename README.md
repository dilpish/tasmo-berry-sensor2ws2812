# Описание - русский
## История изменений

+ 2024-7-26 Наметки
+ 2024-7-29 Ловля багов, добавление трех различных кривых для трех цветов

## Детали
Скрипт запущен на esp32-cam ручной компиляции tasmota из моего соседнего репозитория. Работает достаточно стабильно.

Для проверки и тестирования загрузите `co2-ws2820.be` в файловую систему tasmota и из Berry консоли запустите `load("co2-ws2820.be")`

Для автозагрузки переименуйте файл `co2-ws2820.be` в `autoexec.be`

Кривые я подбирал на этом сайте: https://www.desmos.com/Calculator?lang=ru

## Задача

Задача простая - плавно менять свет ws2812 в зависимости от показания датчика (в данной реализации CO2 - SCD40)

Рулесы в тасмоте работают не всегда стабильно, особенно если это касается переменных, и попытка реализовать что-то вроде этого:

```
Rule2
	ON SCD40#CarbonDioxide!=%Var1% DO BackLog
		IF (%value%<400) var6 400 ELSEIF (%value%>1500) var6 1500 ELSE var6 %value% ENDIF;
		SCALE7 %var6%, 400,1500,0,1;
		var8=(0.5 + 0.5*(1-%var7%*%var7%));
		var9=255*%var8%;
		var10=255*(1-%var7%);
     		Color %var10%, %var9%,0;
     	ENDON
```

Приводит к непонятным багам в переменных - там может оказаться и старое значение, и какой-то полный левак, даже если очищать переменную непосредственно перед использованием.
Поэтому было решено написать драйвер на берри для тасмоты

    


# Description - English
## Details
The script is run on a manually compiled ESP32-CAM with my neighboring Tasmota repository. It works quite stably.

To test and verify, upload the `co2-ws2820.be` file to the Tasmota filesystem and launch `load("co2-ws2820.be")` from the Berry console.

For automatic startup, rename the file `co2-ws2820.be` to autoexec.be.

## Task
The task is simple - smoothly change the light of ws2812 depending on the sensor reading (in this implementation, CO2 - SCD40)

Rules in Tasmota work not always stably, especially if it concerns variables, and if you attempt to realize something like this:

```
Rule2
	ON SCD40#CarbonDioxide!=%Var1% DO BackLog
		IF (%value%<400) var6 400 ELSEIF (%value%>1500) var6 1500 ELSE var6 %value% ENDIF;
		SCALE7 %var6%, 400,1500,0,1;
		var8=(0.5 + 0.5*(1-%var7%*%var7%));
		var9=255*%var8%;
		var10=255*(1-%var7%);
     		Color %var10%, %var9%,0;
     	ENDON
```

Leads to incomprehensible bugs in variables - there can be an old value there, or some complete left, even if you clean the variable directly before use.
Therefore, it was decided to write a driver on Berry for Tasmota.

